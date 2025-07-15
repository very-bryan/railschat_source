# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0.2 application using Ruby 3.4.4. It's a fresh Rails installation with modern defaults including Hotwire (Turbo + Stimulus), Import Maps, Tailwind CSS, and SQLite with database-backed adapters (Solid Queue, Solid Cache, Solid Cable).

## Essential Commands

### Development
- `bin/setup` - Initial setup (installs dependencies, creates database, starts server)
- `bin/dev` - Start development server with Rails + Tailwind watcher
- `bin/rails console` - Open Rails console
- `bin/rails dbconsole` - Open database console

### Testing & Quality
- `bin/rails test` - Run all tests
- `bin/rails test test/path/to/specific_test.rb` - Run a specific test file
- `bin/rails test test/path/to/test.rb:LINE` - Run a specific test at line number
- `bin/rubocop` - Run linter (uses Rails Omakase style)
- `bin/brakeman` - Run security scanner

### Database
- `bin/rails db:create` - Create database
- `bin/rails db:migrate` - Run migrations
- `bin/rails db:seed` - Load seed data
- `bin/rails db:prepare` - Setup database (create + migrate + seed)

### Deployment
- `bin/kamal deploy` - Deploy with Kamal
- `bin/kamal console` - Production Rails console
- `bin/kamal logs` - View production logs

## Architecture & Key Patterns

### Database Architecture
- Uses SQLite for all environments
- Production uses multiple SQLite databases:
  - Primary: `storage/production.sqlite3`
  - Cache: `storage/production_cache.sqlite3`
  - Queue: `storage/production_queue.sqlite3`
  - Cable: `storage/production_cable.sqlite3`

### Frontend Stack
- **CSS**: Tailwind CSS with JIT compilation
- **JavaScript**: Import Maps (no bundler)
- **Interactivity**: Hotwire (Turbo + Stimulus)
- **Assets**: Propshaft for asset pipeline

### Background Processing
- Solid Queue for jobs (database-backed, no Redis required)
- Can run in-process with Puma in production (`SOLID_QUEUE_IN_PUMA=true`)

### Deployment
- Docker-based deployment using Kamal
- Production Dockerfile with multi-stage build
- Runs as non-root user (UID 1000)
- Uses Thruster for HTTP caching/compression

### Testing
- Minitest framework (Rails default)
- Parallel testing enabled
- System tests with Capybara + Selenium
- Fixtures for test data

## Development Workflow

1. Always run `bin/rubocop` before committing to ensure code style compliance
2. Use `bin/dev` for development (includes Tailwind watcher)
3. Test files mirror app structure (e.g., `app/models/user.rb` → `test/models/user_test.rb`)
4. Use Rails generators for consistency: `bin/rails generate model/controller/scaffold`
5. Encrypted credentials for secrets: `bin/rails credentials:edit`

## Important Notes

- This is a fresh Rails 8 app with no custom business logic yet
- All modern Rails conventions are followed
- No Redis dependency - everything uses SQLite adapters
- Production uses encrypted credentials (requires `RAILS_MASTER_KEY`)
- PWA-ready with manifest and service worker scaffolding

## Rules

- 메인 컬러를 내가 먼저 말하지 않았다면 메인 컬러가 무엇인지 나에게 질문해줘
- UI는 항상 shadcn 스타일로 만들어줘
- 서버를 재시작하는 방법은 ./bin/dev 인데 내가 재시작하면 되니 너가 재시작하지 말고 나에게 재시작 하라고 말해줘
- 아이콘은 rails_icons의 tabler를 사용해줘. 아이콘을 불러오는 호출 함수는 rails_icon이 아니라 icon이야
- 아이콘 목록은 https://tabler.io/icons 여기서 참고해
- turbo stream을 사용한다면 https://github.com/hotwired/turbo-rails 문서를 참고해서 정확하게 개발해줘

- 메일발송은 resend를 사용해줘
- exception_notification gem을 사용해 오류 메일을 thenaeun1@gmail.com으로 발송해줘
- 데이터베이스는 sqlite3를 사용해
- 어드민은 gem 사용 없이 직접 구축해줘
- devide로 로그인, 회원가입을 구현해주고 shadcn 스타일로 만들어줘

- 난 영어를 잘 못하니까 질문은 한글로 해줘

## 현재 구현된 기능들

### 1. 인증 시스템
- Devise + Google OAuth2 로그인 구현
- 사용자 모델: full_name, email, role, avatar_url

### 2. 워크스페이스 시스템
- 멀티 워크스페이스 지원
- 워크스페이스별 데이터 분리

### 3. 주요 기능
- **대시보드**: 통계 및 최근 활동
- **노트**: CRUD, 카테고리, 상태 관리
- **칸반 보드**: 드래그앤드롭, 상태별 관리
- **캘린더**: 이벤트 관리
- **채팅**: 실시간 메시징 (Action Cable)
- **보고서**: 분석 및 통계
- **설정**: 워크스페이스 및 개인 설정
- **프로필**: 개인정보 관리, 알림 설정

### 4. UI/UX 특징
- shadcn 스타일 컴포넌트
- 라이트 모드 (다크 모드는 CSS만 준비됨)
- 메인 컬러: #FF6D75 (핑크)
- Tailwind CSS 사용
- Stimulus 컨트롤러로 인터랙션 구현

### 5. 기술 스택
- Rails 8.0.2 + Ruby 3.4.4
- Hotwire (Turbo + Stimulus)
- Import Maps (번들러 없음)
- SQLite (Solid Queue/Cache/Cable)
- Docker + Kamal 배포

### 6. 개발 시 주의사항
- 라이트모드와 다크모드 클래스를 섞지 않기
- 다크모드는 아직 구현하지 않음 (CSS만 준비)
- 모든 UI는 기존 스타일과 일관성 유지
- 아이콘은 항상 icon 헬퍼 사용

## 최근 구현 사항 (2025-07-11)

### 1. 이메일/비밀번호 로그인
- Devise 기본 인증에 이메일/비밀번호 로그인 추가
- Google OAuth2와 함께 사용 가능
- 로그인 폼을 shadcn 스타일로 구현

### 2. 관리자 대시보드
- `/admin` 경로로 접근 (관리자만 접근 가능)
- 전용 어드민 레이아웃 (다크 사이드바)
- 구현된 관리 기능:
  - **대시보드**: 전체 통계, 최근 사용자, 워크스페이스별 노트 수
  - **사용자 관리**: 목록, 상세보기, 편집, 삭제, 관리자 권한 토글
  - **워크스페이스 관리**: 목록, 상세보기, 편집, 삭제
  - **노트 관리**: 목록, 상세보기, 삭제

### 3. 알림 시스템
- 다양한 알림 타입 지원 (노트 할당, 메시지, 시스템 공지 등)
- 알림 우선순위 및 읽음/안읽음 관리
- 헤더에 알림 벨 아이콘 (읽지 않은 개수 표시)
- 알림 페이지에서 필터링 및 일괄 읽음 처리
- NotificationService로 알림 생성 자동화

### 4. 파일 업로드 기능
- Active Storage를 활용한 파일 첨부
- 노트에 다중 파일 첨부 가능
- 이미지 미리보기 지원
- 파일 다운로드 기능
- 파일 타입 및 크기 표시

### 5. 프로필 기능 개선
- 사용자 프로필 페이지 (`/profile`)
- 드롭다운 메뉴로 접근
- 알림 설정 토글 (이메일, 메시지, 작업, 공지)
- 계정 삭제 시 콘텐츠 보존 (익명화)

### 6. 추가 개선사항
- User 모델에 `name` 메서드 추가
- 모든 뷰에서 `full_name` 대신 `name` 사용으로 통일
- 워크스페이스 description 필드 추가
- 페이지네이션 추가 (Kaminari gem)

## 데이터베이스 구조

### 주요 테이블
- `users`: 사용자 정보, 알림 설정, 권한
- `workspaces`: 워크스페이스 정보
- `notes`: 노트 데이터, 파일 첨부
- `notifications`: 알림 데이터
- `categories`: 노트 카테고리
- `statuses`: 노트 상태
- `channels`: 채팅 채널
- `messages`: 채팅 메시지
- `active_storage_*`: 파일 업로드 관련

## 추가 구현 사항 (2025-07-11 오후)

### 7. 검색 기능 개선
- 전역 검색 바를 헤더에 추가
- 통합 검색 페이지 개선 (노트, 채널, 메시지, 사용자)
- SQLite 대소문자 구분 없는 검색 (LOWER 함수 사용)
- 최근 검색어 저장 및 표시
- 검색 결과 필터링 (전체/노트/채널/메시지/사용자)
- 첨부파일 개수 표시

### 8. 협업 기능 강화
- **댓글 시스템**: 노트에 댓글 작성/삭제 기능
- 댓글 파일 첨부 지원
- 댓글 알림 (작성자 및 다른 댓글 작성자에게)
- Turbo Streams를 활용한 실시간 댓글 업데이트
- **실시간 Presence**: 노트를 보고 있는 사용자 표시
- Action Cable을 활용한 실시간 업데이트

## 기술적 구현 사항

### 모델 구조
- Comment 모델 (polymorphic, 파일 첨부 가능)
- 알림 타입에 'note_commented' 추가
- Note와 User에 comments 관계 추가

### 실시간 기능
- NotePresenceChannel: 노트 조회자 실시간 추적
- Rails 캐시를 활용한 조회자 목록 관리
- Stimulus 컨트롤러로 프론트엔드 업데이트

### 검색 최적화
- 워크스페이스별 검색 범위 제한
- includes를 활용한 N+1 쿼리 방지
- 검색 결과 제한 (노트 50개, 채널/메시지/사용자 20개)

### 9. 워크스페이스 멤버 관리
- 워크스페이스 관리자가 멤버를 관리하는 기능
- 이메일로 멤버 초대
- 역할 변경 (관리자/멤버)
- 멤버 제거 기능
- 멤버 목록 페이지 (`/workspace_members`)

### 10. 슈퍼 관리자 시스템
- **접속 방법**: `/super_admin/login` (별도 로그인 페이지)
- **기본 계정**: admin@example.com / password
- **슈퍼 관리자 권한 부여**: `bin/rails admin:make_super`
- **주요 기능**:
  - 📊 시스템 대시보드: 전체 워크스페이스, 사용자, 활성 사용자, 노트, 스토리지 통계
  - 🏢 워크스페이스 관리: 모든 워크스페이스 조회/편집/삭제, 제한 설정
  - 👥 사용자 관리: 모든 사용자 조회/편집/삭제, 슈퍼 관리자 권한 부여/제거, 사용자로 로그인(impersonate)
  - 💳 결제 관리: 구독 플랜 현황 (플레이스홀더)
  - 📈 분석: 사용자 증가 추이, 콘텐츠 통계, 활동 분석
  - ⚙️ 시스템 설정: 가입 허용, 이메일 인증, 유지보수 모드 등

### 기술적 구현 사항
- 슈퍼 관리자는 워크스페이스와 무관하게 시스템 전체에 접근
- 별도의 레이아웃 (`super_admin.html.erb`) 사용
- 다크 테마 사이드바
- 차트는 Chart.js 활용
- 아이콘 문제로 임시로 이모지 사용 중

## 최근 구현 사항 (2025-07-13~15) - 채팅 기능 대폭 개선

### 11. 채팅 UI/UX 개선
- **우측 채널 목록**: 채팅 화면 오른쪽에 채널 목록 사이드바 추가
- **채널 멤버 관리**: 
  - 멤버 추가/제거 기능
  - 관리자 권한 표시 (Admin 뱃지)
  - 실시간 멤버 수 업데이트
- **채널 생성 플로우 개선**: 
  - 2단계 프로세스 (멤버 선택 → 채널 정보 입력)
  - 선택된 멤버 이름으로 채널명 자동 생성
  - 3명 이상일 경우 "이름1, 이름2, 이름3 외" 형식
- **채널 검색**: 실시간 채널 검색 기능

### 12. 채널 즐겨찾기 기능
- **즐겨찾기 토글**: 채널 헤더의 별 아이콘으로 즐겨찾기 추가/제거
- **좌측 사이드바 표시**: 즐겨찾기한 채널만 좌측 메뉴에 표시
- **색상 표시**: 즐겨찾기 채널은 핑크색(#FF6D75)으로 강조
- **데이터 모델**: channel_favorites 테이블로 관리

### 13. 스레드 답글 기능
- **스레드 뷰**: 우측 슬라이드 패널로 스레드 표시
- **답글 그룹화**: 같은 사용자의 연속 메시지는 이름/아바타 생략
- **중복 전송 방지**: 엔터키 연타 시 메시지 중복 전송 차단
- **Turbo 호환성**: Turbo 7+ 버전에 맞춰 수동 Stream 처리

### 14. 메시지 파일 첨부 기능
- **다중 파일 업로드**: 드래그 앤 드롭 또는 파일 선택
- **지원 파일 형식**: 
  - 이미지: JPEG, PNG, GIF, WebP
  - 동영상: MP4, MPEG, QuickTime, AVI, WMV, WebM (최대 50MB)
  - 문서: PDF, Word, Excel, PowerPoint
  - 기타: ZIP, RAR, 텍스트 파일
- **Cloudinary 연동**: 이미지 최적화 및 썸네일 생성
- **미리보기**: 이미지 그리드 뷰, 동영상 플레이어, 파일 아이콘

### 15. 링크 프리뷰 기능
- **YouTube 프리뷰**: 영상 임베드 자동 표시
- **Google Docs 프리뷰**: 문서 타입별 아이콘 및 링크
- **일반 웹 링크**: Open Graph 메타데이터 활용한 프리뷰 카드
- **LinkPreviewService**: 웹 페이지 메타데이터 추출

### 16. 이모지 반응 기능
- **빠른 이모지 선택**: 6개 기본 이모지 + 더보기
- **반응 표시**: 이모지별 카운트 및 사용자 목록
- **툴팁**: 반응한 사용자 목록 표시 (10명 이상 시 스크롤)
- **실시간 업데이트**: Action Cable을 통한 실시간 반영

### 17. 메시지 고정 기능
- **상단 고정 바**: 고정된 메시지 미리보기
- **순환 표시**: 여러 메시지 고정 시 클릭으로 순환
- **권한 관리**: 작성자 또는 관리자만 고정/해제 가능
- **실시간 업데이트**: Turbo Streams로 즉시 반영

### 18. 메시지 공유 기능
- **채널 간 공유**: 같은 워크스페이스 내 다른 채널로 메시지 공유
- **공유 표시**: 그레이 카드 UI로 공유된 메시지 구분
- **원본 정보 유지**: 원작성자, 출처 채널 표시
- **첨부파일 공유**: 파일 복사 없이 참조로 공유

### 19. 메시지 툴바 개선
- **통합 툴바**: 이모지, 답글, 수정, 복사, 핀, 더보기
- **복사 기능**: 클립보드에 메시지 내용 복사
- **권한별 표시**: 자신의 메시지만 수정 버튼 표시
- **일관된 UI**: 모든 메시지에 동일한 툴바 구성

### 20. 메시지 수정 UX 개선
- **동적 입력 필드**: 
  - 한 줄 메시지: `<input>` 필드
  - 여러 줄 메시지: `<textarea>` 필드
- **자동 높이 조정**: 내용에 맞춰 입력창 높이 자동 조절
- **키보드 단축키**:
  - Enter: 저장
  - Shift+Enter: 줄바꿈 (textarea에서만)
  - Esc: 취소

### 21. 노트 첨부 기능
- **노트 선택 모달**: 워크스페이스 내 노트 검색 및 선택
- **노트 프리뷰**: 메시지에 노트 카드 표시
- **카테고리/상태 표시**: 노트의 메타정보 함께 표시
- **클릭 시 이동**: 노트 상세 페이지로 바로 이동

### 22. 멘션(@) 기능
- **@ 자동완성**: @ 입력 시 채널 멤버 검색 드롭다운 표시
- **한글 지원**: 영문, 한글 이름 모두 멘션 가능 (@bryan, @지민)
- **키보드 네비게이션**: 
  - 화살표 키: 사용자 선택
  - Enter/Tab: 선택 확정
  - Escape: 자동완성 닫기
- **멘션 알림**: 멘션된 사용자에게 알림 발송 (NotificationService)
- **멘션 스타일**: 보라색(#9333EA) 배경으로 하이라이트
- **멘션 클릭**: 클릭 시 해당 사용자 프로필로 이동
- **데이터 모델**: message_mentions 테이블로 멘션 관계 관리
- **정규표현식**: `@([가-힣a-zA-Z0-9_]+)` 패턴으로 한글/영문 매칭

## 채팅 기능 기술 명세

### 주요 기능 목록
1. **채널 관리**
   - 채널 생성/삭제
   - 공개/비공개 채널
   - 멤버 초대/제거
   - 관리자 권한 관리
   - 즐겨찾기 기능

2. **메시지 기능**
   - 실시간 메시지 전송/수신 (Action Cable)
   - 메시지 수정/삭제
   - 파일 첨부 (이미지, 동영상, 문서)
   - 링크 프리뷰 (YouTube, Google Docs, 일반 웹)
   - 노트 첨부
   - 메시지 공유
   - 메시지 고정
   - 이모지 반응
   - 답글/스레드
   - 멘션 (@사용자명)

3. **UI/UX 기능**
   - 메시지 그룹화 (같은 사용자 연속 메시지)
   - 날짜 구분선
   - 읽음 표시
   - 입력 중 표시
   - 자동 스크롤
   - 툴바 액션 (hover 시 표시)

### 데이터베이스 스키마

#### channels 테이블
- `id`: bigint (PK)
- `name`: string (채널명)
- `description`: text (설명)
- `is_private`: boolean (비공개 여부)
- `workspace_id`: bigint (FK)
- `created_at`, `updated_at`: datetime

#### channel_members 테이블
- `id`: bigint (PK)
- `channel_id`: bigint (FK)
- `user_id`: bigint (FK)
- `role`: string (admin/member)
- `created_at`, `updated_at`: datetime

#### channel_favorites 테이블
- `id`: bigint (PK)
- `channel_id`: bigint (FK)
- `user_id`: bigint (FK)
- `created_at`: datetime

#### messages 테이블
- `id`: bigint (PK)
- `channel_id`: bigint (FK)
- `user_id`: bigint (FK)
- `body`: text (메시지 내용)
- `parent_message_id`: bigint (답글 대상)
- `thread_root_id`: bigint (스레드 루트)
- `note_id`: bigint (첨부된 노트)
- `is_pinned`: boolean (고정 여부)
- `pinned_at`: datetime
- `edited_at`: datetime
- `shared_from_message_id`: bigint (공유 원본)
- `shared_from_channel_id`: bigint (공유 출처)
- `shared_by_user_id`: bigint (공유한 사용자)
- `created_at`, `updated_at`: datetime

#### message_reactions 테이블
- `id`: bigint (PK)
- `message_id`: bigint (FK)
- `user_id`: bigint (FK)
- `emoji`: string
- `created_at`: datetime

#### message_reads 테이블
- `id`: bigint (PK)
- `message_id`: bigint (FK)
- `user_id`: bigint (FK)
- `read_at`: datetime

#### message_mentions 테이블
- `id`: bigint (PK)
- `message_id`: bigint (FK)
- `user_id`: bigint (FK)
- `created_at`, `updated_at`: datetime
- 인덱스: `[message_id, user_id]` (unique)

### API 엔드포인트

#### 채널 관련
- `GET /channels` - 채널 목록
- `POST /channels` - 채널 생성
- `GET /channels/:id/members` - 멤버 목록
- `POST /channels/:id/update_members` - 멤버 추가/제거
- `POST /channels/:id/toggle_favorite` - 즐겨찾기 토글
- `GET /channels/:id/mentionable_users` - 멘션 가능한 사용자 목록

#### 메시지 관련
- `POST /channels/:channel_id/messages` - 메시지 전송
- `PATCH /messages/:id` - 메시지 수정
- `DELETE /messages/:id` - 메시지 삭제
- `POST /messages/:id/reactions` - 이모지 반응
- `POST /messages/:id/pin` - 메시지 고정
- `POST /messages/:id/share` - 메시지 공유
- `GET /messages/:id/thread` - 스레드 조회

### 실시간 기능 (Action Cable)

#### ChatChannel
- 구독: `channel_#{channel_id}`
- 액션:
  - `speak`: 메시지 전송
  - `typing`: 입력 중 상태
  - `read`: 읽음 처리

#### ChannelReactionsChannel  
- 구독: `channel_#{channel_id}_reactions`
- 실시간 이모지 반응 업데이트

### 파일 업로드
- Active Storage 사용
- Cloudinary 연동 (이미지 최적화)
- 지원 형식:
  - 이미지: 25MB 제한
  - 동영상: 50MB 제한
  - 문서: 25MB 제한

## 채팅 기능 개발 시 주의사항

### 뷰 파일 일관성 (중요!)
- **`chat/show.html.erb`와 `chat/index.html.erb`는 항상 동일한 기능과 UI를 유지해야 함**
- **한쪽을 수정하면 반드시 다른 쪽도 동일하게 수정**
- 특히 다음 기능들은 두 뷰에서 완전히 동일하게 작동해야 함:
  - 메시지 전송 후 커서 유지
  - 자동 높이 조절
  - 스레드 기능
  - 답글 기능
  - 이모지 반응
  - 파일 첨부
  - 검색 기능
- 컨트롤러에서 사용하는 변수명도 일관성 유지:
  - `@current_channel`: 현재 선택된 채널
  - `@channels`: 채널 목록
  - `@messages`: 메시지 목록

### 공통 Partial 사용
- `messages/_form.html.erb`: 메시지 입력 폼
- `messages/_message.html.erb`: 메시지 표시
- `messages/_message_grouped.html.erb`: 그룹화된 메시지
- `chat/_pinned_messages_bar.html.erb`: 고정 메시지 바
- 새로운 기능은 가능한 partial로 분리하여 재사용

### JavaScript 함수 공유
- 스레드 기능: `showThread()`, `sendThreadReply()`, `formatThreadMessage()`
- 메시지 액션: `editMessage()`, `deleteMessage()`, `toggleReaction()`, `copyMessage()`, `shareMessage()`
- 채널 관리: `toggleFavorite()`, `toggleMembersModal()`, `updateSelectedMembers()`
- 고정 메시지: `togglePinMessage()`, `cycleThroughPinnedMessages()`
- 두 뷰에서 동일한 JavaScript 함수를 사용하도록 유지

### 스타일 가이드
- 메인 컬러: #FF6D75 (핑크)
- 채팅 영역 패딩: p-4 (1rem)
- 메시지 간격: space-y-1
- 채널 목록 너비: w-64
- 헤더 높이: 54px (채팅), 64px (메인)
- 공유 메시지: 그레이 카드 UI (slate 계열)

### 성능 최적화
- 이미지 지연 로딩 (Intersection Observer)
- Cloudinary 썸네일 생성
- 메시지 그룹화로 DOM 노드 감소
- Turbo Streams 수동 처리로 포커스 유지

## 앞으로 구현 가능한 기능
- 알림 이메일 발송 (Resend 활용)
- 웹소켓을 활용한 실시간 알림 푸시
- 노트 동시 편집 (Operational Transformation)
- 멘션(@) 기능
- 노트 버전 관리
- 팀 권한 관리 세분화
- 결제 시스템 연동
- 워크스페이스별 사용량 제한 적용
- 채팅 메시지 검색
- 파일 업로드 및 이미지 공유
- 음성/화상 통화 기능