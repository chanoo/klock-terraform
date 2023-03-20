# klock-terraform

Terraform은 인프라스트럭처를 코드로 작성하고 관리하는 데 사용되는 오픈 소스 도구입니다. Terraform을 사용하면 클라우드 서비스 제공 업체, 가상 머신, 네트워크 리소스 등의 인프라를 안전하고 반복 가능한 방식으로 생성, 변경 및 관리할 수 있습니다. Terraform은 선언형 언어인 HashiCorp Configuration Language (HCL)를 사용하여 인프라 구성을 기술합니다.

# 시작

Terraform을 사용하여 AWS 리소스를 관리하려면 다음 단계를 따르세요.

1. Terraform 설치
먼저 Terraform을 설치해야 합니다. 다음과 같이 설치할 수 있습니다.

macOS에서 Homebrew를 사용하는 경우:

```
brew install terraform
```

2. Terraform 프로젝트 디렉토리 생성 및 초기화

프로젝트 루트에 terraform 디렉토리를 생성하고 초기화합니다.


```
git clone https://github.com/chanoo/klock-terraform
cd klock-terraform
terraform init
```

3. Terraform 실행

AWS 리소스를 생성하려면 terraform apply 명령을 실행합니다.

```
terraform apply
```
