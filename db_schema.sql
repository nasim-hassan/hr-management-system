-- Enable required extensions
create extension if not exists "pgcrypto";

-- Enum types
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('hrAdmin', 'manager', 'employee');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'designation_type') THEN
    CREATE TYPE designation_type AS ENUM (
      'intern',
      'juniorDeveloper',
      'seniorDeveloper',
      'technicalLead',
      'manager',
      'director',
      'cto',
      'ceo'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'attendance_status') THEN
    CREATE TYPE attendance_status AS ENUM (
      'present',
      'absent',
      'halfDay',
      'onLeave',
      'remote'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'leave_type') THEN
    CREATE TYPE leave_type AS ENUM (
      'annual',
      'sick',
      'casual',
      'maternity',
      'paternity',
      'unpaid'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'leave_status') THEN
    CREATE TYPE leave_status AS ENUM (
      'pending',
      'approved',
      'rejected',
      'cancelled'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_type') THEN
    CREATE TYPE notification_type AS ENUM (
      'leaveApproved',
      'leaveRejected',
      'attendanceReminder',
      'payslipReady',
      'performanceReview',
      'announcement'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_type') THEN
    CREATE TYPE report_type AS ENUM (
      'attendance',
      'payroll',
      'employee',
      'performance',
      'other'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_status') THEN
    CREATE TYPE report_status AS ENUM (
      'pending',
      'generated',
      'failed'
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'review_status') THEN
    CREATE TYPE review_status AS ENUM (
      'pending',
      'completed',
      'inProgress'
    );
  END IF;
END
$$;

-- Users table (profile metadata)
create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  full_name text,
  role user_role not null default 'employee',
  phone_number text,
  profile_image text,
  is_active boolean not null default true,
  department text,
  designation text,
  join_date date,
  manager_id uuid references users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- Employees table
create table if not exists employees (
  id integer primary key generated always as identity (start with 1000000 increment by 1) check (id between 1000000 and 9999999),
  user_id uuid not null unique references users(id),
  first_name text not null,
  last_name text not null,
  email text not null,
  phone_number text not null,
  address text,
  city text,
  state text,
  zip_code text,
  country text,
  date_of_birth date not null,
  gender text,
  marital_status text,
  date_of_joining date not null,
  designation designation_type not null default 'intern',
  department text not null,
  manager uuid references users(id),
  base_salary numeric,
  allowances numeric,
  deductions numeric,
  account_number text,
  bank_name text,
  ifsc_code text,
  pan_number text,
  aadhar_number text,
  emergency_contact text,
  emergency_contact_number text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- Attendance table
create table if not exists attendance (
  id uuid primary key default gen_random_uuid(),
  employee_id integer not null references employees(id),
  date date not null,
  check_in_time timestamptz,
  check_out_time timestamptz,
  status attendance_status not null default 'absent',
  notes text,
  location text,
  latitude numeric,
  longitude numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  unique (employee_id, date)
);

-- Leave requests table
create table if not exists leave_requests (
  id uuid primary key default gen_random_uuid(),
  employee_id integer not null references employees(id),
  leave_type leave_type not null default 'casual',
  start_date date not null,
  end_date date not null,
  number_of_days int not null,
  reason text,
  status leave_status not null default 'pending',
  approved_by uuid references users(id),
  approved_date timestamptz,
  rejection_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- Payroll table
create table if not exists payroll (
  id uuid primary key default gen_random_uuid(),
  employee_id integer not null references employees(id),
  month int not null,
  year int not null,
  base_salary numeric not null,
  bonus numeric,
  deductions numeric,
  allowances numeric,
  net_salary numeric not null,
  payment_date date not null,
  payslip_url text,
  transaction_id text,
  is_paid boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  unique (employee_id, month, year)
);

-- Notifications table
create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id),
  type notification_type not null default 'announcement',
  title text not null,
  message text not null,
  related_id text,
  related_type text,
  data jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default now(),
  read_at timestamptz
);

-- Holidays table
create table if not exists holidays (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  date date not null,
  end_date date,
  is_custom boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- Reports table
create table if not exists reports (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  type report_type not null default 'other',
  generated_by uuid not null references users(id),
  status report_status not null default 'pending',
  date_range_start date,
  date_range_end date,
  file_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- Performance reviews table
create table if not exists performance_reviews (
  id uuid primary key default gen_random_uuid(),
  employee_id integer not null references employees(id),
  reviewed_by uuid not null references users(id),
  review_year int not null,
  review_quarter int not null,
  overall_rating numeric not null,
  performance_score numeric not null,
  strengths text,
  areas_for_improvement text,
  comments text,
  status review_status not null default 'pending',
  review_date date not null,
  next_review_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  unique (employee_id, review_year, review_quarter)
);

-- Performance Indexes
create index if not exists idx_employees_user_id on employees(user_id);
create index if not exists idx_employees_manager on employees(manager);
create index if not exists idx_attendance_employee_date on attendance(employee_id, date);
create index if not exists idx_leave_requests_employee on leave_requests(employee_id);
create index if not exists idx_payroll_employee on payroll(employee_id);
create index if not exists idx_notifications_user_id on notifications(user_id);
create index if not exists idx_performance_reviews_employee on performance_reviews(employee_id);

-- Enable RLS on all tables
alter table users enable row level security;
alter table employees enable row level security;
alter table attendance enable row level security;
alter table leave_requests enable row level security;
alter table payroll enable row level security;
alter table notifications enable row level security;
alter table holidays enable row level security;
alter table reports enable row level security;
alter table performance_reviews enable row level security;

-- Helper function to avoid RLS infinite recursion
create or replace function get_current_user_role()
returns text as $$
  select role::text from public.users where id = auth.uid();
$$ language sql security definer;

-- Helper policies
create policy users_select_policy on users
  for select using (
    auth.uid() = id
    or get_current_user_role() in ('hrAdmin', 'manager')
  );

create policy users_update_policy on users
  for update using (
    auth.uid() = id
    or get_current_user_role() = 'hrAdmin'
  );

create policy users_insert_auth on users
  for insert with check (
    auth.uid() IS NOT NULL
  );

create policy users_delete_policy on users
  for delete using (
    auth.uid() = id
    or get_current_user_role() = 'hrAdmin'
  );

create policy employees_select on employees
  for select using (
    auth.uid() = user_id
    or manager = auth.uid()
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy employees_insert_admin on employees
  for insert with check (
    user_id = auth.uid()
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy employees_update_admin on employees
  for update using (
    auth.uid() = user_id
    or manager = auth.uid()
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy employees_delete_admin on employees
  for delete using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy attendance_select on attendance
  for select using (
    exists (
      select 1 from employees e
      where e.id = employee_id
        and (
          e.user_id = auth.uid()
          or e.manager = auth.uid()
        )
    )
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy attendance_insert on attendance
  for insert with check (
    exists (
      select 1 from employees e
      where e.id = employee_id
        and e.user_id = auth.uid()
    )
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy attendance_update_admin on attendance
  for update using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy attendance_delete_admin on attendance
  for delete using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy leave_requests_select on leave_requests
  for select using (
    exists (
      select 1 from employees e
      where e.id = employee_id
        and (
          e.user_id = auth.uid()
          or e.manager = auth.uid()
        )
    )
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy leave_requests_insert on leave_requests
  for insert with check (
    exists (
      select 1 from employees e
      where e.id = employee_id
        and e.user_id = auth.uid()
    )
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy leave_requests_update_manager_or_admin on leave_requests
  for update using (
    exists (
      select 1 from employees e
      where e.id = employee_id
        and e.manager = auth.uid()
    )
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy leave_requests_delete_admin on leave_requests
  for delete using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy payroll_select on payroll
  for select using (
    exists (
      select 1 from employees e
      where e.id = employee_id
        and (
          e.user_id = auth.uid()
          or e.manager = auth.uid()
        )
    )
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy payroll_insert_admin on payroll
  for insert with check (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy payroll_update_admin on payroll
  for update using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy payroll_delete_admin on payroll
  for delete using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy notifications_select on notifications
  for select using (
    user_id = auth.uid()
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy notifications_insert on notifications
  for insert with check (
    user_id = auth.uid()
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy notifications_update_own on notifications
  for update using (
    user_id = auth.uid()
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy notifications_delete_admin on notifications
  for delete using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy holidays_select on holidays
  for select using (auth.role() = 'authenticated');

create policy holidays_insert_admin on holidays
  for insert with check (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy holidays_update_admin on holidays
  for update using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy holidays_delete_admin on holidays
  for delete using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy reports_select on reports
  for select using (
    generated_by = auth.uid()
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role in ('hrAdmin', 'manager')
    )
  );

create policy reports_insert_admin_or_manager on reports
  for insert with check (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role in ('hrAdmin', 'manager')
    )
  );

create policy reports_update_admin on reports
  for update using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy reports_delete_admin on reports
  for delete using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

create policy performance_reviews_select on performance_reviews
  for select using (
    exists (
      select 1 from employees e
      where e.id = employee_id
        and e.user_id = auth.uid()
    )
    or reviewed_by = auth.uid()
    or exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role in ('hrAdmin', 'manager')
    )
  );

create policy performance_reviews_insert_admin_or_manager on performance_reviews
  for insert with check (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role in ('hrAdmin', 'manager')
    )
  );

create policy performance_reviews_update_admin_or_manager on performance_reviews
  for update using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role in ('hrAdmin', 'manager')
    )
  );

create policy performance_reviews_delete_admin on performance_reviews
  for delete using (
    exists (
      select 1 from users u
      where u.id = auth.uid()
        and u.role = 'hrAdmin'
    )
  );

-- Grant schema permissions for Supabase user roles
grant usage on schema public to postgres, anon, authenticated, service_role;

-- Grant table-level access to postgres, service_role, authenticated, and anon roles
-- (RLS policies will enforce actual rows visibility)
grant select, insert, update, delete on public.users to postgres, service_role, authenticated, anon;
grant select, insert, update, delete on public.employees to postgres, service_role, authenticated, anon;
grant select, insert, update, delete on public.attendance to postgres, service_role, authenticated, anon;
grant select, insert, update, delete on public.leave_requests to postgres, service_role, authenticated, anon;
grant select, insert, update, delete on public.payroll to postgres, service_role, authenticated, anon;
grant select, insert, update, delete on public.notifications to postgres, service_role, authenticated, anon;
grant select, insert, update, delete on public.holidays to postgres, service_role, authenticated, anon;
grant select, insert, update, delete on public.reports to postgres, service_role, authenticated, anon;
grant select, insert, update, delete on public.performance_reviews to postgres, service_role, authenticated, anon;