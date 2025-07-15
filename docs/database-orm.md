# 데이터베이스 및 ORM 구조

## 개요

이 프로젝트는 **Ruby on Rails의 Active Record ORM**을 사용하여 데이터베이스를 관리합니다. Active Record는 Rails의 기본 ORM(Object-Relational Mapping)으로, 데이터베이스 테이블을 Ruby 클래스에 매핑하여 객체지향적으로 데이터베이스를 다룰 수 있게 해줍니다.

## 데이터베이스 정보

- **데이터베이스 시스템**: SQLite3
- **환경별 설정**:
  - 개발: `storage/development.sqlite3`
  - 프로덕션: 
    - Primary: `storage/production.sqlite3`
    - Cache: `storage/production_cache.sqlite3`
    - Queue: `storage/production_queue.sqlite3`
    - Cable: `storage/production_cable.sqlite3`

## ORM 사용 예시

### 1. 모델 정의

```ruby
class User < ApplicationRecord
  # 관계 설정
  has_many :workspace_members, dependent: :destroy
  has_many :workspaces, through: :workspace_members
  has_many :notes, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  # 검증
  validates :email, presence: true, uniqueness: true
  
  # 콜백
  after_create :create_default_workspace
  
  # 스코프
  scope :admins, -> { where(admin: true) }
  scope :super_admins, -> { where(super_admin: true) }
end
```

### 2. 마이그레이션

```ruby
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.boolean :admin, default: false
      t.boolean :super_admin, default: false
      t.timestamps
    end
    
    add_index :users, :email, unique: true
  end
end
```

### 3. 쿼리 예시

#### 기본 쿼리
```ruby
# 단일 레코드 조회
user = User.find(1)
user = User.find_by(email: "admin@example.com")

# 여러 레코드 조회
users = User.where(admin: true)
users = User.where("created_at > ?", 30.days.ago)

# 정렬
notes = Note.order(created_at: :desc)
notes = Note.order(priority: :desc, created_at: :asc)
```

#### 관계를 통한 쿼리
```ruby
# N+1 쿼리 방지를 위한 includes
notes = Note.includes(:user, :category, :status)

# JOIN을 사용한 쿼리
active_workspaces = Workspace.joins(:notes)
                            .where(notes: { created_at: 7.days.ago.. })
                            .distinct

# 집계 쿼리
workspace_sizes = Workspace.joins(:users)
                          .group('workspaces.id')
                          .count('users.id')
```

#### 복잡한 쿼리
```ruby
# 서브쿼리를 사용한 예
inactive_workspace_ids = Workspace.joins(:notes)
                                 .where(notes: { created_at: 7.days.ago.. })
                                 .pluck(:id)
inactive_workspaces = Workspace.where.not(id: inactive_workspace_ids)

# Raw SQL (필요한 경우)
results = ActiveRecord::Base.connection.execute(
  "SELECT COUNT(*) FROM users WHERE created_at > date('now', '-30 days')"
)
```

### 4. 관계 설정

#### 일대다 관계 (One-to-Many)
```ruby
class Workspace < ApplicationRecord
  has_many :notes
  has_many :channels
  has_many :workspace_members
end

class Note < ApplicationRecord
  belongs_to :workspace
  belongs_to :user
  belongs_to :category, optional: true
end
```

#### 다대다 관계 (Many-to-Many)
```ruby
class User < ApplicationRecord
  has_many :workspace_members
  has_many :workspaces, through: :workspace_members
end

class Workspace < ApplicationRecord
  has_many :workspace_members
  has_many :users, through: :workspace_members
end

class WorkspaceMember < ApplicationRecord
  belongs_to :user
  belongs_to :workspace
end
```

#### 다형성 관계 (Polymorphic)
```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user
end

class Note < ApplicationRecord
  has_many :comments, as: :commentable
end
```

#### 자기 참조 관계 (Self-referential)
```ruby
class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'
end
```

### 5. 스코프와 메서드

```ruby
class Note < ApplicationRecord
  # 스코프
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  
  # 클래스 메서드
  def self.search(query)
    where("LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)", 
          "%#{query}%", "%#{query}%")
  end
  
  # 인스턴스 메서드
  def overdue?
    due_date.present? && due_date < Date.current
  end
end
```

### 6. 콜백 (Callbacks)

```ruby
class Comment < ApplicationRecord
  # 콜백 정의
  after_create :send_notification
  before_destroy :cleanup_notifications
  
  private
  
  def send_notification
    NotificationService.new(self).send_comment_notifications
  end
  
  def cleanup_notifications
    Notification.where(
      notifiable_type: 'Comment',
      notifiable_id: id
    ).destroy_all
  end
end
```

### 7. 트랜잭션

```ruby
class WorkspaceMembersController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      user = User.find_or_create_by!(email: params[:email]) do |u|
        u.password = SecureRandom.hex(16)
        u.first_name = params[:email].split('@').first
      end
      
      @member = @workspace.workspace_members.create!(
        user: user,
        role: params[:role] || 'member'
      )
      
      # 트랜잭션 내에서 실패하면 모든 변경사항이 롤백됨
      NotificationService.new(@member).send_invitation!
    end
  rescue ActiveRecord::RecordInvalid => e
    # 에러 처리
  end
end
```

## 주요 모델 구조

### User 모델
- 인증 (Devise)
- 워크스페이스 멤버십
- 노트, 메시지, 알림 소유

### Workspace 모델
- 멀티테넌시 구현
- 사용자, 노트, 채널 포함
- 제한 설정 (max_members, max_storage_mb)

### Note 모델
- 워크스페이스 범위
- 카테고리, 상태 관리
- 파일 첨부 (Active Storage)
- 댓글 (Polymorphic)

### Notification 모델
- 다형성 관계 (notifiable)
- 우선순위, 읽음 상태
- 타입별 처리

## 성능 최적화

### 1. N+1 쿼리 방지
```ruby
# Bad
notes = Note.all
notes.each { |note| puts note.user.name }

# Good
notes = Note.includes(:user)
notes.each { |note| puts note.user.name }
```

### 2. 인덱스 활용
```ruby
# 마이그레이션에서 인덱스 추가
add_index :notes, :workspace_id
add_index :notes, [:workspace_id, :created_at]
add_index :users, :email, unique: true
```

### 3. 카운터 캐시
```ruby
class Note < ApplicationRecord
  belongs_to :workspace, counter_cache: true
end

# workspaces 테이블에 notes_count 컬럼 필요
```

### 4. 배치 처리
```ruby
# 메모리 효율적인 대량 처리
User.find_each(batch_size: 1000) do |user|
  # 처리 로직
end
```

## SQLite 특수 고려사항

### 대소문자 구분 없는 검색
```ruby
# SQLite는 ILIKE를 지원하지 않음
# 대신 LOWER 함수 사용
Note.where("LOWER(title) LIKE LOWER(?)", "%#{query}%")
```

### 동시성 제한
- SQLite는 쓰기 작업에서 전체 데이터베이스 잠금
- 프로덕션에서는 별도 데이터베이스 파일 사용 (cache, queue, cable)

## 마이그레이션 관리

```bash
# 마이그레이션 생성
bin/rails generate migration AddFieldToModel field:type

# 마이그레이션 실행
bin/rails db:migrate

# 마이그레이션 롤백
bin/rails db:rollback

# 데이터베이스 재생성
bin/rails db:drop db:create db:migrate db:seed
```

## 시드 데이터

`db/seeds.rb` 파일에서 초기 데이터 설정:
- 기본 관리자 계정
- 카테고리 및 상태
- 샘플 워크스페이스 및 노트
- 테스트 사용자

## 데이터베이스 백업

### 개발 환경
```bash
sqlite3 storage/development.sqlite3 ".backup storage/backup_$(date +%Y%m%d).sqlite3"
```

### 프로덕션 환경
- Kamal을 통한 자동 백업 설정 권장
- 정기적인 백업 스케줄 구성