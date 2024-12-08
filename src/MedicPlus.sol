// SPDX-License-Identifier: Open software License 3.0(OSL-3.0)
pragma solidity ^0.8.24; 

import "forge-std/Test.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MedicPlusManager is Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public nextCaseId;

    struct CaseFolder{
        uint256 caseId;
        uint256 issueDate;//Indica la fecha de alta
        string [] cids;// Identificadores único del archivo en IPFS
        string name;
        string description;
        address patient;
        bool exists;
    }

    struct FullPermission {
        bool fullAccess; // Acceso total a todos los documentos
        bool temporaryAccess; // Acceso temporal
        uint256 expiration; // Fecha de expiración del permiso temporal (en timestamp)
    }

    struct SpecificPermission {
        // uint256 caseId; // ID del caso específico
        bool hasAccess; // Indica si el permiso específico está otorgado
        uint256 expiration; // Fecha de expiración del permiso específico (en timestamp). Si no la tiene, debe ser 0
    }

    mapping(uint256 => CaseFolder) public cases;//IDs => Carpeta de caso
    mapping(address => CaseFolder []) public userCases;//Paciente => Lista [] de Carpetas de caso
    mapping(address => mapping(address => mapping(uint256 => SpecificPermission))) private specificPermissions;//Doctor => (Paciente => (Caso => Permiso Especifico))
    mapping(address => mapping(address => FullPermission)) private fullPermissions;//Doctor => (Paciente => Permiso General)

    event CaseUploaded(uint256 caseId, string cid, string name, address patient, uint256 issueDate);
    event FullPermissionGranted(address patient, address recipient);
    event CasePermissionGranted(address patient, address recipient, uint256 caseId);
    event FullPermissionRevoqued(address patient, address recipient);
    event CasePermissionRevoqued(address patient, address recipient, uint256 caseId);
    event CaseEdited(uint256 caseId, uint256 editDate);

    error NoFullPermission();
    error NoValidAddress();
    constructor() Ownable(msg.sender){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
    * @dev Sube un nuevo documento al sistema.
    * @param _cid CID del documento en IPFS.
    * @param _description Descripción del documento.
    * @param _patient Dirección del propietario del documento.
    * @param _issueDate Fecha de alta del documento.
    * @notice La función asigna un ID único al documento y lo asocia al propietario. Además, emite un evento indicando que el documento ha sido subido.
    */
    function uploadCase(string calldata _cid, string calldata _name, string calldata _description, address _patient, uint256 _issueDate) external {
    // function uploadCase(string calldata _cid, string calldata _name, string calldata _description, address _patient, string memory _issueDate) external {
        require(_patient != address(0), "Invalid patient address");
        require(bytes(_cid).length > 0, "Invalid CID");
        require(bytes(_name).length > 0, "Invalid name");
        require(bytes(_description).length > 0, "Invalid description");

        string [] storage caseCids = cases[nextCaseId].cids;
        caseCids.push(_cid);

        nextCaseId++;
        cases[nextCaseId] = CaseFolder({
            caseId: nextCaseId,
            issueDate: _issueDate,
            // cid: _cid,
            cids: caseCids,
            name: _name,
            description: _description,
            patient: _patient,
            exists: true
            });

        userCases[_patient].push(cases[nextCaseId]);
        // userCasesIds[_patient].push(caseId);
        emit CaseUploaded(nextCaseId, _cid, _name, _patient, _issueDate);
    }
     /**
     * @notice Edits an existing case with updated CID, name, or description.
     * @dev Only allows editing if the case exists. Updates related lists for the patient after modifications.
     * @param _caseId The ID of the case to be edited.
     * @param _cid The new CID to append to the case's list of CIDs. If empty, it won't be updated.
     * @param _name The new name for the case. If empty, it won't be updated.
     * @param _description The new description for the case. If empty, it won't be updated.
     * @custom:reverts "Case does not exist" if the provided case ID does not correspond to an existing case.
     * @custom:emits CaseEdited when the case is successfully updated.
     */   

     /**
     * @notice Edita un caso existente con un CID, nombre o descripción actualizados.
     * @dev Solo permite editar si el caso existe. Actualiza las listas relacionadas para el paciente después de las modificaciones.
     * @param _caseId El ID del caso que se va a editar.
     * @param _cid El nuevo CID que se debe agregar a la lista de CIDs del caso. Si está vacío, no se actualizará.
     * @param _name El nuevo nombre para el caso. Si está vacío, no se actualizará.
     * @param _description La nueva descripción para el caso. Si está vacío, no se actualizará.
     * @notice emits CaseEdited cuando el caso se actualiza exitosamente.
     * @custom:reverts "El caso no existe" si el ID de caso proporcionado no corresponde a un caso existente.
     */ 
     function editCase(uint256 _caseId, string calldata _cid, string calldata _name, string calldata _description) external {
        CaseFolder storage userCase = cases[_caseId];
        require(userCase.exists, "Case does not exist");
        uint256 editDate = block.timestamp;
        //QUIEN puede editar un caso? Rol?
        // require(userCase.patient == msg.sender, "Unauthorized");

        if(bytes(_cid).length > 0){
            // string [] storage caseCids = cases[_caseId].cids;
            userCase.cids.push(_cid);
        }
        if(bytes(_name).length > 0){
            userCase.name = _name;
        }
        if(bytes(_description).length > 0){
            userCase.description = _description;
        }
        
        userCase.issueDate = editDate;
           // Reemplazar el caso actualizado en la lista del paciente

        address patient = userCase.patient;
        for (uint256 i = 0; i < userCases[patient].length; i++) {
            if (userCases[patient][i].caseId == _caseId) {
                userCases[patient][i] = userCase;
                break;
            }
        }

        // userCasesIds[_patient].push(caseId);
        emit CaseEdited(_caseId, editDate);
    }

    /** 
    * @dev Concede acceso completo a todos los documentos del remitente a una dirección específica.
    * @param _recipient Dirección que recibe los permisos.
    * @param _expiration Fecha de expiración del permiso (en timestamp).
    * @notice Si se especifica una expiración, el permiso se considera temporal y se revocará automáticamente después de la fecha indicada.
    * @notice Si no se desea especificar una expiración, _expiration debe ser 0
    */
    function grantFullPermission(address _recipient, uint256 _expiration) external {
        // require(_recipient != address(0), "Invalid recipient address");
        if(_recipient == address(0)){
            revert NoValidAddress();
        }
        fullPermissions[_recipient][msg.sender].fullAccess = true;

        if(_expiration > 0){
            require(_expiration > block.timestamp, "Expiration must be in the future");
            fullPermissions[_recipient][msg.sender].temporaryAccess = true;
            fullPermissions[_recipient][msg.sender].expiration = _expiration;
        }
        emit FullPermissionGranted(msg.sender,_recipient);
        
    } 
    
    /**
    * @dev Concede permisos de acceso a documentos específicos a una dirección.
    * @param _recipient Dirección que recibe los permisos de acceso.
    * @param _caseId ID del caso al que se concede acceso.
    * @param _expiration Fecha de expiración del permiso (en timestamp).
    * @notice Si se especifica una expiración, el permiso para cada documento será temporal y se revocará automáticamente después de la fecha indicada.
    * @notice Si no se desea una fecha de una expiración, _expiration debe ser 0.
    */
    function grantCasePermission(address _recipient, uint256 _caseId, uint256 _expiration) external {
        require(_caseId > 0, "Invalid caseId. Must be greater than 0");
        require(_recipient != address(0), "Invalid recipient address");

        specificPermissions[_recipient][msg.sender][_caseId].hasAccess = true;
        if(_expiration > 0){
            require(_expiration > block.timestamp, "Expiration must be in the future");
            specificPermissions[_recipient][msg.sender][_caseId].expiration = _expiration;
        }
        emit CasePermissionGranted(msg.sender,_recipient,_caseId);
    }

    /**
    * @dev Revoca el acceso completo de una dirección a todos los documentos del remitente.
    * @param _recipient Dirección cuyo permiso será revocado.
    * @notice Emite un evento indicando que el permiso completo ha sido revocado.
    */
    function revokeFullPermission(address _recipient) external {
        require(_recipient != address(0), "Invalid recipient address");
        require(fullPermissions[_recipient][msg.sender].fullAccess, "Recipient does not have full access");
        
        delete fullPermissions[_recipient][msg.sender].fullAccess;
        delete fullPermissions[_recipient][msg.sender].temporaryAccess;
        delete fullPermissions[_recipient][msg.sender].expiration;
        // if(permissions[msg.sender][_recipient].temporaryAccess){
        //     delete permissions[msg.sender][_recipient].temporaryAccess;
        //     delete permissions[msg.sender][_recipient].expiration;
        // }
        emit FullPermissionRevoqued(msg.sender,_recipient);
    }
    /**
    * @dev Revoca el acceso a documentos específicos de una dirección.
    * @param _recipient Dirección cuyo permiso será revocado.
    * @param _caseId ID del caso cuyo permiso serán revocado.
    * @notice Emite un evento indicando que el permiso del caso ha sido revocado.
    */  
    function revokeCasePermission(address _recipient, uint256 _caseId) external {
        require(_caseId > 0, "Invalid caseId. Must be greater than 0");
        require(_recipient != address(0), "Invalid recipient address");
        require(specificPermissions[_recipient][msg.sender][_caseId].hasAccess, "Recipient does not have permission");

        delete specificPermissions[_recipient][msg.sender][_caseId];
        emit CasePermissionRevoqued(msg.sender,_recipient,_caseId);    
    }
    /**
    * @dev Verificar si un destinatario tiene acceso a un documento.
    * @param _patient Dirección del propietario del documento.
    * @param _recipient Dirección del destinatario que solicita acceso.
    * @param _caseId Identificador único del caso.
    * @return bool `true` si el destinatario tiene acceso al documento, de lo contrario `false`.
    */
    function hasAccess(address _patient,address _recipient, uint256 _caseId) external view returns (bool) {
        FullPermission memory fullPermission = fullPermissions[_recipient][_patient];
        if(_caseId == 0){
            return fullPermission.fullAccess || fullPermission.temporaryAccess;
        }
        SpecificPermission memory specificPermission = specificPermissions[_recipient][_patient][_caseId];
        return(specificPermission.hasAccess || specificPermission.expiration > block.timestamp);
    }  
    
    /**
    * @dev Obtener todos los casos completos de un usuario.
    * @param _patient Dirección del usuario cuyos documentos se solicitarán.
    * @return Document[] Array de casos completos del usuario.
    */
    function getAllCases(address _patient) external view returns (CaseFolder[] memory) {
        return userCases[_patient];
    }

    /**
    * @dev Obtener los detalles completos de un caso especifico.
    * @param _caseId Identificador único del caso.
    * @return Document Información detallada del caso solicitado.
    */
    function getCase(uint256 _caseId) external view returns (CaseFolder memory) {
        require(cases[_caseId].exists, "Document does not exist");
        return cases[_caseId];
    }

    /**
     * @notice Checks if a full permission is active for a recipient to access a patient's case or general records.
     * @dev Validates both full and case-specific permissions, including expiration times.
     * @param _recipient The address of the entity attempting to access the data.
     * @param _patient The address of the patient whose data is being accessed.
     * @param _caseId The ID of the case being accessed. If 0, checks general full permissions.
     * @return A boolean indicating whether the permission is active and valid.
     * @custom:reverts NoFullPermission if a general full permission exists but has expired.
     * @custom:reverts "Patient does not have permission" if case-specific permissions are expired or invalid.
     */
    /**
    * @notice Verifica si una autorización completa está activa para un destinatario para acceder a un caso de un paciente o registros generales.
    * @dev Valida las autorizaciones completas y específicas de caso, incluyendo los tiempos de expiración.
    * @param _recipient La dirección de la entidad que intenta acceder a los datos.
    * @param _patient La dirección del paciente cuyos datos se están accediendo.
    * @param _caseId El ID del caso que se está accediendo. Si es 0, se verifican autorizaciones completas generales.
    * @return Un booleano que indica si la autorización está activa y es válida.
    * @custom:reverts NoFullPermission si existe una autorización completa general pero ha expirado.
    */
    function isFullPermissionActive(address _recipient,address _patient, uint256 _caseId) external view returns (bool) {
        
    if(_caseId == 0){
        if(fullPermissions[_recipient][_patient].expiration != 0 &&
        fullPermissions[_recipient][_patient].expiration < block.timestamp){
            revert NoFullPermission();
        }
        
        // require (fullPermissions[_recipient][_patient].expiration == 0 || fullPermissions[_recipient][_patient].expiration > block.timestamp, "Patient does not have full access");
        return fullPermissions[_recipient][_patient].fullAccess;
    }else{
        require(specificPermissions[_recipient][_patient][_caseId].expiration == 0 || specificPermissions[_recipient][_patient][_caseId].expiration > block.timestamp, "Patient does not have permission");        
        return specificPermissions[_recipient][_patient][_caseId].hasAccess;
    }
    }

     /**
     * @notice Checks if a temporary permission is active for a recipient to access a patient's data.
     * @dev Differentiates between general temporary permissions and case-specific permissions.
     * @param _recipient The address of the entity attempting to access the data.
     * @param _patient The address of the patient whose data is being accessed.
     * @param _caseId The ID of the case being accessed. If 0, checks general temporary permissions.
     * @return A boolean indicating whether the temporary permission is active.
     */

     /**
     * @notice Verifica si una autorización temporal está activa para un destinatario para acceder a los datos de un paciente.
     * @dev Diferencia entre autorizaciones temporales generales y específicas de caso.
     * @param _recipient La dirección de la entidad que intenta acceder a los datos.
     * @param _patient La dirección del paciente cuyos datos se están accediendo.
     * @param _caseId El ID del caso que se está accediendo. Si es 0, se verifican autorizaciones temporales generales.
     * @return Un booleano que indica si la autorización temporal está activa.
     */
    function isTemporaryPermissionActive(address _recipient,address _patient, uint256 _caseId) external view returns (bool) {
        if(_caseId == 0){
            return fullPermissions[_recipient][_patient].temporaryAccess;
        }else{
            return specificPermissions[_recipient][_patient][_caseId].expiration > block.timestamp;
        }
    }
    // function getSpecificPermissions(address patient) external view returns (SpecificPermission[] memory) {
    //     return specificPermissions[patient][msg.sender];
    // }
}
