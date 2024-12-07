// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4; //REVISAR VERSION

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MedicPlusManager is Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public nextCaseId;

    struct CaseFolder{
        uint256 caseId;
        uint256 issueDate;//Indica la fecha de alta
        string cid;// Identificador único del archivo en IPFS
        string name;
        string description;
        address patient;
        bool exists;
    }

    // struct SepecificPermission{
    //     bool hassAccess;
    //     uint256 expiration;
    // }

//REVISAR PERMISSION especifico, linea 32 mal, solo permitiria tener un permiso para un solo caso a la vez
    struct Permission{//REVISAR
        bool fullAccess;// Acceso total a todos los documentos
        bool temporaryAccess;//Acceso temporal
        uint256 expiration;//Fecha de expiración del permiso temporal(en timestamp)
        // mapping(Permission => SpecificPermission) specificPermissions;//Permisos especificos para ciertos casos
        // uint256 caseId; //ID del caso específico al que se aplica el permiso. Es 0 si no hay case especifico
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
    // mapping(address => mapping(address => Permission)) private permissions;//Doctor => (Paciente => Permiso General)
    mapping(address => mapping(address => FullPermission)) private fullPermissions;//Doctor => (Paciente => Permiso General)

    event CaseUploaded(uint256 caseId, string cid, string name, address patient, string issueDate);
    event FullPermissionGranted(address patient, address recipient);
    event CasePermissionGranted(address patient, address recipient, uint256 caseId);
    event FullPermissionRevoqued(address patient, address recipient);
    event CasePermissionRevoqued(address patient, address recipient, uint256 caseId);
    constructor() Ownable(msg.sender){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function uploadCase(string calldata _cid, string calldata _name, string calldata _description, address _patient, string _issueDate) external {
        require(_patient != address(0), "Invalid patient address");
        require(bytes(_cid).length > 0, "Invalid CID");
        require(bytes(_name).length > 0, "Invalid name");
        require(bytes(_description).length > 0, "Invalid description");

        uint256 caseId = nextCaseId++;
        cases[caseId] = CaseFolder({
            caseId: caseId,
            issueDate: _issueDate,
            cid: _cid,
            name: _name,
            description: _description,
            patient: _patient,
            exists: true
            });

        userCases[_patient].push(cases[caseId]);
        // userCasesIds[_patient].push(caseId);
        emit CaseUploaded(caseId, _cid, _name, _patient, _issueDate);
    }

    function grantFullPermission(address _recipient, uint256 _expiration) external {
        require(_recipient != address(0), "Invalid recipient address");

        permissions[_recipient][msg.sender].fullAccess = true;

        if(_expiration > 0){
            require(_expiration > block.timestamp, "Expiration must be in the future");
            fullPermissions[[_recipient][msg.sender]].temporaryAccess = true;
            fullPermissions[[_recipient][msg.sender]].expiration = _expiration;
        }
        emit FullPermissionGranted(msg.sender,_recipient);
        
    } 
    

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

    function revokeFullPermission(address _recipient) external {
        require(_recipient != address(0), "Invalid recipient address");
        require(permissions[_recipient][msg.sender].fullAccess, "Recipient does not have full access");
        
        delete permissions[_recipient][msg.sender].fullAccess;

        // if(permissions[msg.sender][_recipient].temporaryAccess){
        //     delete permissions[msg.sender][_recipient].temporaryAccess;
        //     delete permissions[msg.sender][_recipient].expiration;
        // }
        emit FullPermissionRevoqued(msg.sender,_recipient);
    }
    function revokeCasePermission(address _recipient, uint256 _caseId) external {
        require(_caseId > 0, "Invalid caseId. Must be greater than 0");
        require(_recipient != address(0), "Invalid recipient address");
        require(specificPermissions[_recipient][msg.sender][_caseId].hasAccess, "Recipient does not have permission");

        delete specificPermissions[_recipient][msg.sender][_caseId];
        emit CasePermissionRevoqued(msg.sender,_recipient,_caseId);    
    }

    function hasAccess(address _patient,address _recipient, uint256 _caseId) external view returns (bool) {
        FullPermission fullPermission = fullPermissions[_recipient][patient];
        SpecificPermission specificPermission = specificPermissions[_recipient][patient][_caseId];

        return fullPermission.fullAccess || fullPermission.temporaryAccess || (specificPermission.hasAccess || specificPermission.temporaryAccess);
    }
    function getAllCases(address _patient) external view returns (CaseFolder[] memory) {
        return userCases[_patient];
    }

    function getCase(uint256 _caseId) external view returns (CaseFolder memory) {
        require(cases[_id].exists, "Document does not exist");
        return cases[_id];
    }
    function isFullPermission(address _patient) external view returns (bool) {
        return fullPermissions[msg.sender][_patient].fullAccess;
    }
    function isCaseFullPermission(address _patient, uint256 _caseId) external view returns (bool) {
        return specificPermissions[msg.sender][_patient][_caseId].expiration == 0;
    }
    function getSpecificPermissions(address patient) external view returns (SpecificPermission[] memory) {
        return specificPermissions[patient];
    }
}
