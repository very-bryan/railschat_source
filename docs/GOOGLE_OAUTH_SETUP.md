# Google OAuth 설정 상세 가이드

## 📋 사전 준비사항
- Google 계정
- Google Cloud Console 접근 권한

## 🚀 설정 단계

### 1️⃣ Google Cloud Console 프로젝트 생성

1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 상단 프로젝트 선택 드롭다운 → "새 프로젝트" 클릭
   ![프로젝트 생성](https://via.placeholder.com/600x300?text=New+Project)
3. 프로젝트 정보 입력:
   - **프로젝트 이름**: Workspace App (또는 원하는 이름)
   - **조직**: 개인 계정인 경우 "조직 없음"
4. "만들기" 클릭

### 2️⃣ OAuth 동의 화면 구성

1. 왼쪽 메뉴: **API 및 서비스** → **OAuth 동의 화면**
2. User Type 선택:
   - ✅ **외부**: 모든 Google 사용자 로그인 가능 (추천)
   - ❌ **내부**: Google Workspace 조직 내부만 가능
3. "만들기" 클릭
4. 앱 정보 입력:
   ```
   앱 이름: 워크스페이스
   사용자 지원 이메일: your-email@gmail.com
   앱 로고: (선택사항)
   앱 도메인: (선택사항)
   개발자 연락처: your-email@gmail.com
   ```
5. "저장 후 계속"

### 3️⃣ 범위(Scopes) 설정

1. "범위 추가 또는 삭제" 클릭
2. 필터에 "userinfo" 검색
3. 다음 항목 체크:
   - ✅ `.../auth/userinfo.email` - 이메일 주소 보기
   - ✅ `.../auth/userinfo.profile` - 개인정보 보기
4. "업데이트" → "저장 후 계속"
5. 테스트 사용자는 건너뛰고 "저장 후 계속"

### 4️⃣ OAuth 2.0 클라이언트 ID 생성

1. 왼쪽 메뉴: **API 및 서비스** → **사용자 인증 정보**
2. 상단 **"+ 사용자 인증 정보 만들기"** → **"OAuth 클라이언트 ID"**
3. 설정:
   ```
   애플리케이션 유형: 웹 애플리케이션
   이름: 워크스페이스 웹앱
   ```
4. **승인된 JavaScript 원본** (선택사항):
   ```
   http://localhost:3000
   ```
5. **승인된 리디렉션 URI** (필수):
   ```
   http://localhost:3000/users/auth/google_oauth2/callback
   ```
   프로덕션 배포 시 추가:
   ```
   https://yourdomain.com/users/auth/google_oauth2/callback
   ```
6. "만들기" 클릭

### 5️⃣ 인증 정보 저장

팝업에서 표시되는 정보를 복사:
- **클라이언트 ID**: `123456789-xxxxx.apps.googleusercontent.com`
- **클라이언트 보안 비밀번호**: `GOCSPX-xxxxxxxxxxxxx`

### 6️⃣ Rails 앱에 설정

1. `.env` 파일 열기
2. 복사한 값 붙여넣기:
   ```bash
   GOOGLE_CLIENT_ID=123456789-xxxxx.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxx
   ```
3. 파일 저장

### 7️⃣ 서버 재시작
```bash
./bin/dev
```

## ⚠️ 주의사항

### 리디렉션 URI 오류 해결
"redirect_uri_mismatch" 에러가 나는 경우:
1. Google Console에서 설정한 URI와 정확히 일치하는지 확인
2. 끝에 슬래시(/) 없어야 함
3. http/https 구분 확인
4. 포트 번호 확인 (개발: 3000)

### 승인 오류 해결
"access_blocked" 에러가 나는 경우:
1. OAuth 동의 화면이 "게시됨" 상태인지 확인
2. 테스트 모드인 경우 테스트 사용자 추가

### 프로덕션 배포 시
1. 프로덕션 도메인으로 리디렉션 URI 추가
2. HTTPS 필수
3. OAuth 동의 화면 검증 필요할 수 있음

## 🔍 디버깅 팁

### 환경 변수 확인
```bash
rails console
> ENV['GOOGLE_CLIENT_ID']
> ENV['GOOGLE_CLIENT_SECRET']
```

### 로그 확인
```bash
tail -f log/development.log
```

## 📚 참고 자료
- [Google OAuth 2.0 문서](https://developers.google.com/identity/protocols/oauth2)
- [Devise Omniauth 문서](https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview)