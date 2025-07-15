# Git 사용 가이드 - 초보자를 위한 완벽한 안내서

## 📌 Git이란?

Git은 코드의 변경 사항을 추적하고 관리하는 도구입니다. 마치 문서의 '버전 관리'와 같은 개념입니다.
- 작업한 내용을 저장하고 되돌릴 수 있습니다
- 여러 사람과 협업할 수 있습니다
- 코드의 히스토리를 관리할 수 있습니다

## 🚀 기본 명령어

### 1. 현재 상태 확인하기
```bash
git status
```
- 어떤 파일이 변경되었는지 확인할 수 있습니다
- 커밋할 준비가 된 파일들을 볼 수 있습니다

### 2. 변경사항 추가하기
```bash
# 특정 파일만 추가
git add 파일명

# 모든 변경사항 추가
git add .

# 예시
git add app/models/user.rb
git add app/views/users/show.html.erb
```

### 3. 커밋하기 (저장하기)
```bash
# 간단한 메시지로 커밋
git commit -m "사용자 프로필 페이지 추가"

# 여러 줄 메시지로 커밋
git commit -m "사용자 프로필 기능 추가

- 프로필 보기 페이지 구현
- 프로필 수정 기능 추가
- 아바타 업로드 기능 포함"
```

### 4. 커밋 기록 보기
```bash
# 전체 기록 보기
git log

# 간단하게 한 줄로 보기
git log --oneline

# 최근 5개만 보기
git log --oneline -n 5

# 그래프로 보기
git log --graph --oneline
```

### 5. 이전 상태로 되돌리기
```bash
# 작업 중인 변경사항 임시 저장
git stash

# 임시 저장한 내용 다시 불러오기
git stash pop

# 특정 파일의 변경사항 취소
git checkout -- 파일명

# 마지막 커밋 취소 (조심해서 사용!)
git reset --soft HEAD~1
```

## 📝 일반적인 작업 흐름

### 새로운 기능 추가하기
1. 코드 수정/추가
2. 상태 확인: `git status`
3. 변경사항 추가: `git add .`
4. 커밋: `git commit -m "기능 설명"`

### 예시: 새로운 페이지 추가
```bash
# 1. 파일들을 수정하거나 생성한 후

# 2. 어떤 파일이 변경되었는지 확인
git status

# 3. 모든 변경사항을 스테이징 영역에 추가
git add .

# 4. 커밋하기
git commit -m "대시보드 페이지 추가"

# 5. 커밋이 잘 되었는지 확인
git log --oneline -n 1
```

## 🌿 브랜치 사용하기

브랜치는 메인 코드와 별도로 작업할 수 있는 독립적인 작업 공간입니다.

### 브랜치 기본 명령어
```bash
# 현재 브랜치 확인
git branch

# 새 브랜치 만들기
git branch 브랜치명

# 브랜치 이동하기
git checkout 브랜치명

# 브랜치 만들고 바로 이동하기
git checkout -b 브랜치명

# 예시
git checkout -b feature/user-profile
```

### 브랜치 병합하기
```bash
# main 브랜치로 이동
git checkout main

# feature 브랜치를 main에 병합
git merge feature/user-profile

# 병합 후 필요없는 브랜치 삭제
git branch -d feature/user-profile
```

## 🔄 원격 저장소 (GitHub) 사용하기

### 원격 저장소 연결
```bash
# 원격 저장소 추가
git remote add origin https://github.com/사용자명/저장소명.git

# 원격 저장소 확인
git remote -v
```

### 코드 올리기 (Push)
```bash
# 처음 올릴 때
git push -u origin main

# 이후부터는
git push
```

### 코드 받기 (Pull)
```bash
# 원격 저장소의 최신 내용 받기
git pull

# 특정 브랜치 받기
git pull origin 브랜치명
```

## 💡 유용한 팁

### 1. 커밋 메시지 작성 요령
- 현재형으로 작성: "추가했다" ❌ → "추가" ⭕
- 구체적으로 작성: "수정" ❌ → "로그인 버그 수정" ⭕
- 한글 또는 영어 중 하나로 통일

좋은 예시:
```
✅ "사용자 프로필 페이지 추가"
✅ "로그인 시 이메일 검증 버그 수정"
✅ "대시보드 통계 기능 구현"
```

나쁜 예시:
```
❌ "수정"
❌ "ㅁㄴㅇㄹ"
❌ "작업함"
```

### 2. .gitignore 파일
특정 파일들을 Git이 추적하지 않도록 설정하는 파일입니다.

```bash
# .gitignore 예시
.DS_Store          # macOS 시스템 파일
.env              # 환경 변수 파일
/log/*            # 로그 파일들
/tmp/*            # 임시 파일들
/storage/*        # 업로드된 파일들
```

### 3. 실수했을 때 대처법

#### 커밋 메시지를 잘못 작성했을 때
```bash
# 마지막 커밋 메시지 수정
git commit --amend -m "올바른 메시지"
```

#### 잘못된 파일을 커밋했을 때
```bash
# 파일을 스테이징에서 제거
git reset HEAD 파일명

# 커밋 자체를 취소 (조심!)
git reset --soft HEAD~1
```

#### 실수로 파일을 삭제했을 때
```bash
# 특정 파일 복구
git checkout -- 파일명

# 모든 변경사항 취소
git checkout -- .
```

## 📊 상태 확인 명령어 모음

```bash
# 현재 상태 확인
git status

# 간단한 상태 확인
git status -s

# 브랜치 확인
git branch

# 원격 저장소 확인
git remote -v

# 최근 커밋 확인
git log --oneline -n 10

# 특정 파일의 변경 이력
git log --oneline 파일명
```

## 🎯 실전 예제

### 예제 1: 새로운 기능 개발하기
```bash
# 1. 새 브랜치 생성 및 이동
git checkout -b feature/notification

# 2. 코드 작업...

# 3. 변경사항 확인
git status

# 4. 변경사항 추가
git add .

# 5. 커밋
git commit -m "알림 기능 추가"

# 6. main 브랜치로 이동
git checkout main

# 7. 병합
git merge feature/notification

# 8. 원격 저장소에 푸시
git push
```

### 예제 2: 버그 수정하기
```bash
# 1. 버그 수정 브랜치 생성
git checkout -b fix/login-error

# 2. 버그 수정...

# 3. 커밋
git add .
git commit -m "로그인 시 null 에러 수정"

# 4. main에 병합
git checkout main
git merge fix/login-error

# 5. 브랜치 삭제
git branch -d fix/login-error
```

## ⚠️ 주의사항

1. **중요한 작업 전에는 항상 커밋하기**
   - 실험적인 작업을 하기 전에 현재 상태를 커밋해두세요

2. **의미 있는 단위로 커밋하기**
   - 너무 많은 변경사항을 한 번에 커밋하지 마세요
   - 기능별, 버그별로 나누어 커밋하세요

3. **민감한 정보 커밋하지 않기**
   - 비밀번호, API 키 등은 절대 커밋하지 마세요
   - .env 파일 사용을 권장합니다

4. **force push 조심하기**
   - `git push -f`는 매우 위험한 명령어입니다
   - 팀으로 작업할 때는 특히 주의하세요

## 🆘 도움이 필요할 때

```bash
# Git 도움말 보기
git help

# 특정 명령어 도움말
git help commit
git help branch
git help merge
```

## 📚 추가 학습 자료

- [Git 공식 문서](https://git-scm.com/doc)
- [GitHub 가이드](https://guides.github.com/)
- [생활코딩 Git 강의](https://opentutorials.org/course/3837)

---

이 가이드는 Rails 프로젝트에서 Git을 사용하는 기본적인 방법을 다룹니다.
더 궁금한 점이 있으면 언제든지 물어보세요! 🚀