# Mejoras Aplicadas y Guía de Buenas Prácticas

Este documento explica every cambio realizado en el proyecto, por qué se hizo y qué debés seguir estudiando para llevar este proyecto de "práctica" a "nivel profesional".

---

## 1. Resumen de Cambios Aplicados

### 1.1. Bug crítico corregido: CIDR de VPC
**Cambio:** `24.0.0.0/16` → `10.0.0.0/16`

**Por qué:** `24.0.0.0/16` es un rango público asignado a algún organismo. AWS **no permite** crear VPCs con CIDRs públicos. El `terraform apply` fallaba sí o sí. Los rangos válidos para VPC privadas son:
- `10.0.0.0/8` (recomendado)
- `172.16.0.0/12`
- `192.168.0.0/16`

**Archivos modificados:**
- `main.tf`
- `modules/networking/variables.tf`
- `modules/networking/main.tf`
- `modules/security_groups/variables.tf`
- `modules/security_groups/main.tf`

---

### 1.2. Agregado: Bloque `terraform {}` y `required_providers`
**Archivo nuevo:** `versions.tf`

**Por qué:** Desde Terraform 0.13+ es obligatorio declarar la versión mínima de Terraform y los providers requeridos con sus versiones. Esto asegura que cualquier persona que clone el repo use la misma versión de AWS provider, evitando sorpresas por cambios breaking.

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**Buenas prácticas relacionadas:**
- Usar `required_version` para no soportar versiones de Terraform muy viejas o muy nuevas sin testing.
- Pinlear el provider con `~> 5.0` (permite parches 5.x, pero no salta a 6.0 sin testing explícito).

---

### 1.3. Mejora: AMI dinámica con `data "aws_ami"`
**Cambio:** Eliminado `ami = "ami-091138d0f0d41ff90"` hardcodeado.

**Por qué:** Las AMIs son regionales y cambian con el tiempo. Hoy esa AMI puede no existir en `us-east-1`, o en otra región, o en tu cuenta. Usar un `data source` consulta la AMI más reciente de Amazon Linux 2 al momento del `plan`.

```hcl
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

**Luego en las instancias:**
```hcl
ami = data.aws_ami.amazon_linux_2.id
```

**Buenas prácticas:**
- Nunca hardcodees IDs de AMI en proyectos reutilizables.
- Usa `most_recent = true` con filtros por nombre de imagen para sistemas Operativos estándar (Amazon Linux, Ubuntu, etc.).
- Si necesitás una AMI específica por compliance, usá Tags o un SSM Parameter.

---

### 1.4. Seguridad: SSH restringido por variable
**Cambio:** `cidr_blocks = ["0.0.0.0/0"]` → `cidr_blocks = [var.allowed_ssh_cidr]`

**Por qué:** Tener SSH abierto a TODO internet es una invitación a fuerza bruta. Incluso en un proyecto de práctica, es una mala práctica documentar código inseguro como "normal".

Ahora podés ejecutar:
```powershell
terraform apply -var="allowed_ssh_cidr=200.123.45.67/32"
```

**Buenas prácticas:**
- En producción, SSH debería venir exclusivamente por un Bastion Host o VPN.
- Si necesitás acceso remoto, usá AWS Systems Manager Session Manager (puerto 443) y cerradu el 22 completamente.

---

### 1.5. Seguridad: S3 hardening
**Cambios en `modules/iam_s3/main.tf`:**

Agregados:
- `aws_s3_bucket_versioning`: habilita versionado para recuperación ante borrados o ransomware.
- `aws_s3_bucket_server_side_encryption_configuration`: cifrado AES-256 por defecto.
- `aws_s3_bucket_public_access_block`: bloquea acceso público, ACLs públicas y políticas públicas en las 4 opciones.

**Por qué:** Un bucket S3 abierto es la causa #1 de brechas de datos en AWS. Incluso en prácticas, demuestra conciencia de seguridad.

**Buenas prácticas:**
- Usar `force_destroy = false` para evitar borrados accidentales.
- Considerar `object_lock` para datos que no deben ser eliminados (WORM - Write Once Read Many).
- Para producción: agregar `bucket_policy` con `aws:SecureTransport = true` para forzar HTTPS.

---

### 1.6. Código: Variables con defaults y validaciones
**Cambio:** Agregadas `validation` blocks a variables críticas.

**Ejemplo en networking:**
```hcl
variable "cidr_vpc" {
  description = "CIDR block de la VPC"
  type        = string
  validation {
    condition     = can(regex("^10\\.", var.cidr_vpc)) || can(regex("^172\\.1[6-9]\\.", var.cidr_vpc)) || can(regex("^192\\.168\\.", var.cidr_vpc))
    error_message = "CIDR debe ser rango privado RFC1918 (10.0.0.0/8, 172.16.0.0/12 o 192.168.0.0/16)."
  }
}
```

**Por qué:** Terraform falla temprano con mensajes claros en lugar de fallar en AWS con errores crípticos.

---

### 1.7. Reutilización: `locals` para tags
**Archivo nuevo:** `locals.tf` en root y en módulos clave.

```hcl
locals {
  common_tags = {
    Project   = "terraform-aws-cluster-practice"
    ManagedBy = "Terraform"
    Owner     = "tu-nombre"
  }
}
```

**Por qué:** Los tags son obligatorios para:
- Cost Allocation (ver cuánto gasta cada proyecto en AWS Cost Explorer).
- Automatización (scripts que buscan recursos por tag).
- Seguridad (policies que condicionan acceso por tags).

**Buenas prácticas:**
- Usar `Environment`, `Team`, `CostCenter`, `Repository` siempre.
- No uses tags conEmojis ni espacios (algunos servicios los rechazan).

---

### 1.8. Código: `for_each` en lugar de `count`
**Cambio en `modules/compute/main.tf`:**

Antes:
```hcl
count = 3
```

Ahora:
```hcl
for_each = {
  "worker-1" = { name = "svr-airflow-worker-1" }
  "worker-2" = { name = "svr-airflow-worker-2" }
  "worker-3" = { name = "svr-airflow-worker-3" }
}
```

**Beneficios:**
- Si eliminas `"worker-2"` del mapa, Terraform destruye solo esa instancia (no renombra índices).
- Podés agregar workers específicos con nombres significativos.
- Los outputs usan keys (`each.key`) en lugar de índices numéricos.

**Estudio recomendado:** Diferencia entre `count` (index-based, frágil) e `for_each` (key-based, idempotente). `for_each` requiere maps o sets, no números.

---

### 1.9. Código: Limpieza de código muerto
**Eliminado:** Variable `cidr_vpc` en `modules/security_groups/variables.tf` que nunca se usaba en el código.

**Por qué:** El código muerto confunde a quien lo lee y hace que los `terraform validate` pasen pero las herramientas de estática (tflint) fallen.

---

### 1.10. Nomenclatura: Estandarización a `snake_case`
**Cambios:**
- `SG_proxy` → `sg_proxy`
- `SVR_proxy` → `svr_proxy`
- `SG_airflow` → `sg_airflow`

**Por qué:** Terraform funciona en ambos casos, pero la convención oficial y la mayoría de los módulos públicos usan `snake_case` para recursos. Mejora la legibilidad y evita confusión con tipos/clases cuando el equipo crece.

---

### 1.11. Robustez: Prevención de destrucción
**Agregado en módulos:**
```hcl
lifecycle {
  prevent_destroy = true
}
```

**Recursos protegidos:**
- VPC (`modules/networking/main.tf`)
- Subredes
- Internet Gateway
- Roles IAM (`modules/iam_s3/main.tf`)

**Por qué:** En un entorno real, borrar una VPC accidentalmente destruye toda la red y puede perder datos o generar horas de downtime. `prevent_destroy` fuerza un `terraform destroy` interactivo que advierte del borrado.

**Ojo:** Esto NO protege contra `terraform destroy -force` (alias moderno de `-force`), pero sí contra destrucciones automáticas en CI/CD mal configuradas.

---

### 1.12. Outputs mejorados
**Agregados outputs más útiles:**
- `vpc_cidr`
- `subnet_publica_cidr`
- `subent_privada_cidr`
- `all_workers_private_ips` (mapa nombre → IP)
- `bucket_arn`
- `iam_user_arn`

**Por qué:** En un pipeline real, necesitás estos valores para conectar otros servicios (Airflow necesita las IPs de RabbitMQ y Workers; un dashboard necesita el ARN del bucket).

---

## 2. Archivos Creados

| Archivo | Descripción |
|---|---|
| `versions.tf` | Versiones de Terraform y AWS provider. |
| `locals.tf` | Variables locales para tags comunes. |
| `MEJORAS_Y_BUENAS_PRACTICAS.md` | Este documento. |

---

## 3. Archivos Modificados

| Archivo | Cambios principales |
|---|---|
| `main.tf` | CIDR corregido, uses de `data.aws_ami`, tags con locals, variables nuevas. |
| `variables.tf` | Variables `allowed_ssh_cidr`, `owner`, `environment` con defaults y validaciones. |
| `outputs.tf` | Outputs expandidos. |
| `modules/networking/main.tf` | Tags, `prevent_destroy`, eliminado `depends_on` innecesario (implícito), multi-AZ preparado (data source). |
| `modules/networking/variables.tf` | Validaciones de CIDR, defaults sensatos. |
| `modules/security_groups/main.tf` | SSH parametrizado, tags, nombres en `snake_case`, egress restringido en descripción. |
| `modules/compute/main.tf` | `for_each` en workers, `data.aws_ami`, tags, outputs nuevos. |
| `modules/compute/variables.tf` | Eliminadas variables sin descripción. |
| `modules/iam_s3/main.tf` | S3 hardening (versioning, SSE, public access block), tags, `prevent_destroy`. |
| `modules/iam_s3/outputs.tf` | ARNs adicionales. |

---

## 4. Cosas que aún podés mejorar (Roadmap)

### 4.1. Nivel Intermedio (antes de publicar)
- [ ] **Backend remoto**: Crear un módulo S3 + DynamoDB para estado compartido. Ejecutá `scripts/bootstrap-backend.sh` una sola vez.
  ```
  aws s3api create-bucket --bucket mi-terraform-state-<random> --region us-east-1
  aws dynamodb create-table --table-name terraform-locks ...
  ```
- [ ] **GitHub Actions**: Workflow que corra `terraform fmt -check`, `terraform validate` y `terraform plan` en cada PR.
- [ ] **Multi-AZ**: Cambiar `single AZ` a dos AZs (`data.aws_availability_zones`).
- [ ] **Eliminar `terraform.tfvars` del repo**: usá variables de entorno (`export TF_VAR_owner=lopez`) o un `.tfvars` local excluido por `.gitignore`.

### 4.2. Nivel Avanzado
- [ ] **`user_data` / cloud-init**: Instalar Docker, Airflow, RabbitMQ automáticamente. Esto convierte las EC2 en algo funcional, no solo cajas vacías.
- [ ] **Terraform Cloud / Atlantis**: Para planes colaborativos sin exponer el backend.
- [ ] **Tests**: `terraform test` (nuevo en Terraform 1.6+) o `terratest` (Go) para validar que el módulo networking crea una VPC con 2 subnets.
- [ ] **Monitoreo**: Módulo para CloudWatch Agent, alarmas de CPU/Memoria y un dashboard básico.
- [ ] ** Alta Disponibilidad**: Auto Scaling Group para workers, Load Balancer para Airflow.
- [ ] **Infraestructura Like Code**: Agregar un `Makefile` o `justfile` con targets: `make plan`, `make apply`, `make destroy`.

---

## 5. Buenas Prácticas Aplicadas (Checklist)

### IaC / Terraform
| Práctica | Estado |
|---|---|
| `terraform {}` + `required_providers` | ✅ Aplicado |
| Versionado de providers en `.terraform.lock.hcl` | ✅ Ya estaba |
| `for_each` en lugar de `count` | ✅ Aplicado |
| `locals` para valores reutilizables | ✅ Aplicado |
| Data sources en lugar de IDs hardcodeados | ✅ Aplicado (AMI) |
| Variables con tipos, descripciones y validaciones | ✅ Aplicado |
| `prevent_destroy` en recursos críticos | ✅ Aplicado |
| Backend remoto documentado | ⏳ Falta (ver roadmap) |
| Estructura de entornos (`dev/`, `prod/`) | ⏳ Falta (ver roadmap) |

### Seguridad
| Práctica | Estado |
|---|---|
| SSH restringido a IP admin | ✅ Aplicado |
| S3 con versioning + SSE + public access block | ✅ Aplicado |
| EBS cifrado | ✅ Ya estaba |
| IAM separado (usuario vs rol) | ✅ Ya estaba |
| Variables sensibles marcadas como `sensitive` | ⏳ Aplicar |
| Tags para costo y auditoría | ✅ Aplicado |
| Sin secretos hardcodeados | ✅ |

### Código
| Práctica | Estado |
|---|---|
| Nomenclatura `snake_case` | ✅ Aplicado |
| Sin código muerto | ✅ Limpiado |
| Nombres de recursos descriptivos | ✅ |
| Archivos de tamaño manejable (< 250 líneas) | ✅ |
| Comentarios explicativos | ✅ |

---

## 6. Comandos para verificar los cambios

```powershell
# 1. Inicializar (descargar providers)
terraform init

# 2. Validar sintaxis
terraform validate

# 3. Formatear todo automáticamente
terraform fmt -recursive

# 4. Ver plan (sin aplicar)
terraform plan

# 5. Aplicar (si estás seguro)
terraform apply

# 6. Ver estado actual
terraform show

# 7. Destruir todo (no olvides hacerlo para no gastar)
terraform destroy
```

**Pro tip:** Usá `terraform plan -out=tfplan` y luego `terraform apply tfplan` para aplicar exactamente lo planeado (evita sorpresas si alguien modificó algo entre plan y apply).

---

## 7. Temas para Estudiar (Sugerencias por tu nivel)

Si estás aprendiendo Terraform y AWS, estos tópicos te harán crecer rápido:

### 7.1. Terraform (Core)
| Tema | Por qué importa | Recursos |
|---|---|---|
| **`terraform state` comandos** | Si perdés el `.tfstate`, no podés modificar ni borrar infra. `state mv`, `state rm` son vitales. | [Terraform State CLI](https://developer.hashicorp.com/terraform/cli/state) |
| **Backends remotos** | S3 + DynamoDB es el estándar. Aprendé de bloqueos, encriptación y acceso. | [Terraform Backend S3](https://developer.hashicorp.com/terraform/language/settings/backends/s3) |
| **Módulos públicos** | Usar `terraform-aws-modules/vpc/aws` en lugar de escribir el tuyo desde cero te da best practices listas. | [Terraform Registry](https://registry.terraform.io/) |
| **`for_each` vs `count` vs `dynamic`** | Diferencia clave para código mantenible. `for_each` para recursos con identidad. | Docs oficiales de `for_each` |
| **`terraform import`** | Para traer recursos creados manualmente bajo gestión de Terraform. | Docs de `import` |
| **Entornos (`tfvars` por ambiente)** | Separar `dev` de `prod` sin duplicar código. | Estructura por directorios |

### 7.2. AWS Networking
| Tema | Por qué importa |
|---|---|
| **VPC Peering / Transit Gateway** | Conectar múltiples VPCs (si tu data platform crece). |
| **VPC Endpoints (Gateway + Interface)** | Acceder a S3 y DynamoDB sin salir a internet. Reduce costo y mejora seguridad. |
| **NACLs vs Security Groups** | Stateless vs Stateful. Entender cuándo usar cada uno. |
| **Bastion Host / Session Manager** | Acceso seguro a instancias privadas. |

### 7.3. AWS Security
| Tema | Por qué importa |
|---|---|
| **IAM Policy condiciones** | `aws:SourceIp`, `aws:SecureTransport`, `s3:prefix` para políticas restrictivas. |
| **AWS Organizations / SCPs** | Límites de cuenta para protegerte de vos mismo. |
| **GuardDuty / Security Hub** | Detectar anomalías (como SSH brute force). |
| **AWS Config** | Auditar si tus recursos cumplen reglas (ej: "todos los buckets deben tener versioning"). |

### 7.4. Data Engineering (tu stack)
| Tema | Por qué importa |
|---|---|
| **MWAA (Managed Airflow)** | En lugar de EC2 autogestionados, AWS ofrece Airflow como servicio. Simplifica mucho. |
| **Amazon EMR / EKS** | Apache Airflow en ECS/EKS con workers en Fargate o managed node groups. |
| **DataBrew / Glue** | Alternativas serverless para ETL en lugar de Spark en EC2. |
| **EventBridge + Step Functions** | Orquestación nativa AWS como reemplazo o complemento de Airflow. |

---

## 8. Errores Comunes que Ahora estás Evitando

1. **Hardcodear IDs de recursos** (AMI, AZ, account ID). Usá data sources o variables.
2. **SSH 0.0.0.0/0** "porque es práctica". Incluso en práctica, parametriza el riesgo para aprender.
3. **Un solo archivo `main.tf` de 500 líneas**. Separar en módulos obliga a pensar interfaces y contratos.
4. **No versionar providers**. Un día el provider de AWS hace un cambio breaking y tu código deja de funcionar sin aviso.
5. **Commeter `.tfstate` o `.tfvars`**. Aunque uses `prevent_destroy`, un leak de `.tfstate` expone toda tu infra.

---

## 9. Próximos Pasos Sugeridos

1. Corré `terraform fmt -recursive` para dar formato a los archivos nuevos.
2. Corré `terraform init` nuevamente para que se genere el lock actualizado.
3. Hacé un commit con los cambios (no olvides `.gitignore` para `.terraform/`).
4. Completá las secciones del `README.md` que faltan (diagrama, flujo de datos, costo estimado por mes).
5. (Opcional) Creá un bucket S3 para el backend y adaptá el código para usarlo.

---

## 10. Recursos Recomendados

- **Libro:** *Terraform: Up & Running* (Yevgeniy Brikman) — Capítulos 4, 5, 7.
- **Curso:** *AWS Certified Solutions Architect Associate* (Stephane Maarek) — Para entender VPC, IAM, EC2 profundamente.
- **Blog:** [HashiCorp Learn](https://learn.hashicorp.com/terraform) — Tutoriales oficiales.
- **Herramienta:** [tflint](https://github.com/terraform-linters/tflint) — Linter para Terraform. Detecta errores que `validate` no ve.
- **Practica:** [Terraform Challenge](https://terraformchallenge.com/) — Ejercicios progresivos.
