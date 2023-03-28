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

## Namespace

```bash
# 모든 네임스페이스 조회
$ kubectl get svc --all-namespaces

# 네임스페이스 삭제
$ kubectl delete ns klock
```

## Deployment

```bash
# 디플로이먼트 목록 가져오기
$ kubectl get deployment -n [NAMESPACE NAME]

# 디플로이먼트 삭제
$ kubectl delete deployment [DEPLOYMENT NAME] -n [NAMESPACE NAME]
```

## Ingress

```bash
# 적용된 Ingress 정보 가져오기
kubectl get ingress -o yaml -n [NAMESPACE NAME]

# Ingress 삭제
kubectl delete ingress [INGRESS NAME] -n [NAMESPACE NAME]
```

## Service

```bash
# 서비스 엔드포인트 가져오기
$ kubectl get endpoints [SERVICE NAME]

# 서비스 삭제
$ kubectl delete service [SERVICE NAME] -n [NAMESPACE NAME]
```

## Pod

```bash
# 포드 목록 조회
$ kubectl get pods -n [NAMESPACE NAME]

# 포드 삭제
$ kubectl delete pod [포드 이름] -n [NAMESPACE NAME]

# 라벨로 포드 정보 가져오기
$ kubectl get pods -l app=klock-api-app-pod -n [NAMESPACE NAME]
```

## 트러블슈팅

```bash
# ALB Controller 로그 확인
$ kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Ingress 연결 확인
$ kubectl get ingress -o wide -n [NAMESPACE NAME]

# Service 연결 확인
$ kubectl get services -o wide -n [NAMESPACE NAME]
```
