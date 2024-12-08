# Descripción del proyecto

# Medic+

**Medic+** es una solución descentralizada diseñada para transformar la gestión y el control de los historiales médicos personales. Basada en tecnología blockchain, garantiza la privacidad y seguridad de los datos, otorgando a los pacientes el control total sobre quién puede acceder a su información y en qué momento.

Con **Medic+**, compartir datos médicos de forma cómoda y segura se convierte en una realidad, permitiendo a los pacientes acceder a todas las posibilidades que ofrece la telemedicina y la prevención avanzada. Esto incluye la facilidad de obtener segundas opiniones o realizar estudios preventivos con cualquier clínica o especialista, tanto de manera presencial como online.

Además, **Medic+** integra un innovador asistente de inteligencia artificial capaz de traducir diagnósticos médicos en términos claros y comprensibles. Este asistente también sugiere estudios adicionales o cambios en los hábitos de vida basados en normativas internacionales, como las guías de la Organización Mundial de la Salud (OMS). Todo esto se realiza con un enfoque en la privacidad del usuario y un análisis avanzado de sus datos médicos.

**Medic+** no solo empodera a los pacientes, sino que también establece un nuevo estándar en la gestión de información médica al combinar seguridad, accesibilidad e innovación tecnológica.

## Características principales

- **Seguridad y control total:** Almacenamiento descentralizado en blockchain para prevenir manipulaciones o pérdidas de datos.
- **Empoderamiento del paciente:** El paciente decide quién accede a su historial médico y cuándo.
- **Acceso global a opiniones médicas:** Se comparten los datos de forma segura con cualquier médico o clínica, ya sea presencial u online, accediendo a todo el potencial de la telemedicina y la prevención avanzado mediante el estudio de los datos.
- **IA alineada con normativas sanitarias:** Garantiza información confiable y ética al operar bajo estándares como los de la OMS y guías nacionales.

## Workflow de Medic+

### 1. Registro de usuario y configuración inicial

- Los pacientes se registran en la plataforma vinculando su identidad con una dirección de wallet descentralizada.
- Se generan claves criptográficas para garantizar la privacidad y seguridad de los datos almacenados en la blockchain.

### 2. Subida de datos médicos

- Los datos médicos (informes, diagnósticos, análisis, etc.) se almacenan en un sistema descentralizado como IPFS o Arweave.
- Los metadatos de los registros se vinculan a un contrato inteligente en la blockchain, donde el paciente conserva el control sobre los permisos de acceso.

### 3. Gestión de permisos

- Los pacientes deciden qué especialistas o instituciones tienen acceso a sus datos y por cuánto tiempo.
- El acceso se verifica mediante el contrato inteligente y requiere la aprobación explícita del paciente.

### 4. Análisis avanzado y asistente de IA

- El asistente de IA analiza los datos médicos almacenados y proporciona:
  - Explicaciones claras de diagnósticos.
  - Recomendaciones basadas en normativas globales, como las guías de la OMS, si son solicitadas.
  - Sugerencias personalizadas para estudios adicionales o cambios en hábitos de vida, si son solicitadas.

### 5. Consulta y telemedicina

- Los datos pueden compartirse fácilmente con médicos u otras instituciones para consultas presenciales u online.
- Toda la interacción está protegida por blockchain, garantizando la privacidad del paciente y la integridad de los datos compartidos.

### 6. Actualización y seguimiento

- Los pacientes pueden añadir nuevos registros médicos y actualizar su información de forma sencilla.
- Los médicos pueden adjuntar notas adicionales, informes o recomendaciones, siempre con la autorización del paciente.

### Flujo de Trabajo Gráfico

![alt text](Flujo-MedicPlus.PNG)

### Arquitectura

![alt text](Arquitectura-MedicPlus.jpeg)

## Tecnologías utilizadas

- **Frontend:** React y Next.js usando Scaffold-Eth 2 para una experiencia fluida.
- **Backend:** FastAPI con Python para la gestión de datos y comunicación con la blockchain.¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿???????????????
- **Blockchain:** Smart contract desarrollado en Solidity con Foundry y desempleado en Arbitrum..
- **Almacenamiento descentralizado:** IPFS para el almacenamiento seguro de datos médicos.
- **IA:** Modelos de machine learning integrados para análisis avanzado de datos.¿¿¿¿¿¿¿¿¿¿¿¿¿¿????????????????

## Cómo contribuir

1. Clona este repositorio:

   ```bash
   git clone https://github.com/tu-repo/medic-plus.git

   ```

2. Instala las dependencias:
   ```bash
   npm install
   ```
3. Configura las claves para blockchain e IPFS en el archivo .env.
4. Corre la aplicación:
   ```bash
   npm run dev
   ```

## Próximos pasos

- Integrar un asistente de IA para consultas acerca de los diagnósticos.
- Ampliar las funcionalidades del asistente de IA con análisis predictivo.
- Integrar un sistema de video conferencia para comunicaciones entre paciente y doctor.
- Mejorar la experiencia de usuario con interfaces más intuitivas.
  Desarrollar una aplicación móvil para mejorar la accesibilidad.
  ¿¿¿¿¿¿¿¿¿¿¿¿???????????????????
