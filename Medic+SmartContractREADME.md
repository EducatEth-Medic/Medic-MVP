# Medic+ Smart Contract

**Medic+ Smart Contract** es el componente central que permite la gestión descentralizada y segura de historiales médicos en la blockchain. Este contrato inteligente garantiza privacidad, seguridad y accesibilidad para los datos médicos de los pacientes.

## Descripción General

El contrato inteligente de Medic+ está diseñado para gestionar la privacidad de los datos médicos de los pacientes y permitir un acceso seguro y controlado por parte de médicos e instituciones autorizadas. Utiliza la blockchain para almacenar metadatos relacionados con registros médicos, proporcionando así una solución robusta contra manipulaciones y accesos no autorizados.

### Funciones principales del contrato

1. **Registro de datos medicos**:

   - **`function uploadCase(string calldata _cid, string calldata _name, string calldata _description, address _patient, uint256 _issueDate) external`**: Almacena un nuevo caso médico en el sistema con un identificador único y una referencia a los datos médicos en IPFS.
   - **`function editCase(uint256 _caseId, string calldata _cid, string calldata _name, string calldata _description) external`**: Permite al propietario actualizar un caso médico de un usuario.

2. **Gestión de permisos**:

   - **`grantFullPermission(address _recipient, uint256 _expiration) external`**: Otorga acceso general a todos los datos médicos de un usuario a otra dirección. El acceso puede tener o no caducidad especificada. Si no hay caducidad \_expiration es 0.
   - **`function grantCasePermission(address _recipient, uint256 _caseId, uint256 _expiration) external`**: Otorga acceso total o temporal a un solo caso de un usuario a otra dirección. El acceso puede tener o no caducidad especificada. Si no hay caducidad \_expiration es 0.
   - **`revokeFullPermission(address _recipient) external`**: Revoca el acceso total de una dirección a los datos de un usuario.
   - **`revokeCasePermission(address _recipient, uint256 _caseId) external`**: Revoca el acceso de una dirección a un caso médico específico de un usuario.

3. **Actualización y seguimiento**:
   - **`function hasAccess(address _patient,address _recipient, uint256 _caseId) external view returns (bool)`**: Permite comprobar si se tiene acceso a los datos médicos de un caso específico. Si es para un permiso general \_caseId es 0.
   - **`function isFullPermissionActive(address _recipient,address _patient, uint256 _caseId) external view returns (bool)`**: Permite comprobar si el permiso total general o para un caso específico está activo. Si es para un permiso general \_caseId es 0.
   - **` function isTemporaryPermissionActive(address _recipient,address _patient, uint256 _caseId) external view returns (bool)`**: Permite comprobar si el permiso temporal general o para un caso específico está activo. Si es para un permiso general \_caseId es 0.
   - **`function getAllCases(address _patient) external view returns (CaseFolder[] memory)`**: Devuelve los datos médicos y metadatos de un usuario.
   - **`function getCase(uint256 _caseId) external view returns (CaseFolder memory)`**: Devuelve los datos médicos y metadatos de un caso específico de un usuario.

## Pruebas con Foundry

Medic+ Smart Contract incluye un conjunto de pruebas unitarias y de integración realizadas con Foundry para garantizar la correcta funcionalidad y seguridad del contrato.

### Cobertura de Pruebas

- **Foundry Tests**: Medic+ cuenta con un archivo de prueba que cubre las funciones principales del contrato.
- **Cobertura de Prueba**: El contrato inteligente ha sido probado exhaustivamente con un 85% de cobertura de línea. Esto asegura que la mayoría de las funcionalidades críticas han sido verificadas.¿¿¿¿¿¿¿¿¿¿¿¿¿¿??????????????????

### Medic+ en Arbitrum

Medic+ ha sido desplegado en la red de arbitrumSepolia y ha sido verificado en Arbiscan
https://sepolia.arbiscan.io/address/0x36c9e9b21c21690e894eb6a5f3a648fe98ee2a97
