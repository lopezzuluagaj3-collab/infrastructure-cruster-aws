# Proyecto Terraform VPC en AWS

Este proyecto usa Terraform para crear una infraestructura base en AWS dentro de la region `us-east-1`.

La infraestructura incluye una VPC, una subred publica, una subred privada, un Internet Gateway, un NAT Gateway, tablas de enrutamiento, grupos de seguridad y varias instancias EC2 para servicios como proxy, RabbitMQ, Airflow y Spark.

## Para que sirve Terraform

Terraform permite definir infraestructura como codigo. En vez de crear recursos manualmente desde la consola de AWS, se escriben en archivos `.tf` y Terraform se encarga de crear, modificar o destruir esos recursos de forma controlada.

Comandos principales:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Requisitos previos

Antes de ejecutar este proyecto necesitas:

- Una cuenta de AWS.
- Un usuario IAM para Terraform.
- AWS CLI instalado.
- Terraform instalado.
- Key pairs creados en EC2 para conectarse por SSH a las instancias.
- Credenciales AWS configuradas en tu maquina.

## 1. Crear usuario IAM en AWS

En AWS IAM crea un usuario, por ejemplo:

```text
terraform-user
```

Ese usuario necesita permisos para administrar recursos EC2, VPC, subnets, security groups, route tables, Internet Gateway, NAT Gateway, Elastic IP e instancias.

Para un laboratorio o practica se puede usar la politica administrada:

```text
AmazonEC2FullAccess
```

Para entornos reales conviene usar una politica mas limitada, con solo los permisos necesarios.

Despues crea una access key para ese usuario:

```text
Access key ID
Secret access key
```

Guarda esos valores porque se usan para configurar AWS CLI.

## 2. Instalar AWS CLI

Descarga AWS CLI desde la documentacion oficial de AWS:

```text
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
```

Despues verifica la instalacion:

```powershell
aws --version
```

Debe mostrar algo parecido a:

```text
aws-cli/2.x.x Python/x.x.x Windows/11 exe/AMD64
```

## 3. Configurar credenciales AWS

Ejecuta:

```powershell
aws configure
```

Ingresa los datos del usuario IAM:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name: us-east-1
Default output format: json
```

Verifica que las credenciales funcionen:

```powershell
aws sts get-caller-identity
```

Si responde con el usuario y la cuenta de AWS, la configuracion esta correcta.

## 4. Instalar Terraform en Windows

Descarga Terraform desde HashiCorp:

```text
https://developer.hashicorp.com/terraform/install
```

Selecciona:

```text
Windows AMD64
```

Descomprime el `.zip` y copia `terraform.exe` en:

```text
C:\terraform\terraform.exe
```

Agrega `C:\terraform` al `PATH` del usuario:

```powershell
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\terraform", "User")
```

Cierra PowerShell, abre uno nuevo y verifica:

```powershell
terraform version
```

Si no funciona por `PATH`, puedes probar directo:

```powershell
C:\terraform\terraform.exe version
```

## 5. Crear key pairs en EC2

Este proyecto usa dos variables:

```hcl
KEY_PROXY
KEY_GENERAL
```

Estas variables representan el nombre de los key pairs creados en AWS EC2.

Importante: `key_name` no recibe la ruta del archivo `.pem`. Recibe el nombre exacto del key pair en AWS.

Ejemplo correcto:

```hcl
KEY_PROXY   = "KEY_PROXY"
KEY_GENERAL = "KEY_GENERAL"
```

Ejemplo incorrecto:

```hcl
KEY_GENERAL = "C:\Users\usuario\Downloads\llave.pem"
```

Puedes listar los key pairs existentes con:

```powershell
aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output table
```

## 6. Variables del proyecto

El archivo `variables.tf` declara las variables:

```hcl
variable "KEY_PROXY" {
  description = "Nombre del key pair de AWS para la instancia proxy."
  type        = string
}

variable "KEY_GENERAL" {
  description = "Nombre del key pair de AWS para las instancias internas."
  type        = string
}
```

El archivo `terraform.tfvars` define los valores:

```hcl
KEY_PROXY   = "KEY_PROXY"
KEY_GENERAL = "KEY_GENERAL"
```

Terraform lee automaticamente `terraform.tfvars` al ejecutar `plan` o `apply`.

## 7. Inicializar Terraform

Desde la carpeta del proyecto:

```powershell
cd C:\Users\lopez\OneDrive\Desktop\terraform\proyecto-vpc
terraform init
```

Este comando descarga el provider de AWS y crea la carpeta `.terraform`.

Tambien genera o actualiza:

```text
.terraform.lock.hcl
```

Ese archivo fija la version del provider usada por el proyecto.

## 8. Validar configuracion

Ejecuta:

```powershell
terraform validate
```

Si todo esta bien, debe mostrar:

```text
Success! The configuration is valid.
```

Esto solo valida que Terraform entiende el codigo. No crea recursos todavia.

## 9. Revisar el plan

Ejecuta:

```powershell
terraform plan
```

Terraform mostrara que recursos va a crear, modificar o destruir.

Para guardar el plan:

```powershell
terraform plan -out=tfplan
```

Luego puedes aplicar exactamente ese plan:

```powershell
terraform apply tfplan
```

## 10. Crear infraestructura

Para crear los recursos:

```powershell
terraform apply
```

Terraform mostrara el plan y pedira confirmacion:

```text
yes
```

Durante la creacion, el NAT Gateway puede tardar varios minutos. Mensajes como este son normales:

```text
aws_nat_gateway.nat_gw: Still creating...
```

## 11. Borrar toda la infraestructura

Como este proyecto fue teorico o de practica, lo mas importante al terminar es destruir los recursos para evitar costos.

Ejecuta:

```powershell
terraform destroy
```

Confirma con:

```text
yes
```

Tambien puedes crear un plan de destruccion:

```powershell
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

No borres `terraform.tfstate` antes de hacer `destroy`. Ese archivo le dice a Terraform que recursos creo y que debe eliminar.

## Recursos creados por este proyecto

El archivo `main.tf` crea principalmente:

- VPC `VPC_curter`.
- Subnet publica `Subnet-Publica`.
- Subnet privada `Subnet-Privada`.
- Internet Gateway.
- Elastic IP para NAT Gateway.
- NAT Gateway.
- Tabla de rutas publica.
- Tabla de rutas privada.
- Security group para proxy.
- Security group para Airflow.
- Security group para workers de Airflow.
- Security group para RabbitMQ.
- Security group para Spark master.
- Security group para Spark workers.
- Instancia EC2 proxy `t3.micro`.
- Instancia EC2 RabbitMQ `t3.small`.
- Instancia EC2 Airflow master `t3.small`.
- Instancia EC2 Spark master `t3.small`.
- Tres instancias EC2 Spark workers `t3.small`.
- Instancia EC2 Airflow worker `t3.small`.

## Notas importantes

- El NAT Gateway genera costo mientras exista.
- Las instancias EC2 generan costo mientras esten encendidas.
- Los volumenes EBS tambien pueden generar costo.
- Si el `apply` falla a mitad de camino, revisa el estado con `terraform plan`.
- Si un recurso queda marcado como `tainted`, Terraform puede proponer destruirlo y crearlo de nuevo.
- Los security groups del proxy abren puertos como SSH, HTTP y HTTPS hacia `0.0.0.0/0`; para produccion conviene limitar SSH a tu IP publica.
- El CIDR configurado actualmente usa `24.0.0.0/16`. Para proyectos reales normalmente se usan rangos privados como `10.0.0.0/16`, `172.16.0.0/16` o `192.168.0.0/16`.

## Comandos utiles

Ver identidad AWS configurada:

```powershell
aws sts get-caller-identity
```

Ver key pairs disponibles:

```powershell
aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output table
```

Ver estado de Terraform:

```powershell
terraform show
```

Ver recursos manejados por Terraform:

```powershell
terraform state list
```

Validar formato de archivos Terraform:

```powershell
terraform fmt
```

Validar configuracion:

```powershell
terraform validate
```

Crear recursos:

```powershell
terraform apply
```

Eliminar recursos:

```powershell
terraform destroy
```


