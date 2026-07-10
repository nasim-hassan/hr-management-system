-- =========================================================================
-- HR Management System: Bangladeshi Aspect Mock Data SQL Script (FULLY CORRECTED)
-- =========================================================================
-- This script contains sample data with Bangladeshi names, local holidays,
-- BDT salaries, and local address structures.
--
-- BEFORE RUNNING:
-- Under the UNIQUE constraints, each employee record requires a corresponding
-- row in the "users" table. We have provided optional "users" inserts at the 
-- top in case you need to register them.
--
-- Admin credentials (pre-inserted):
-- ID: 69d27032-c059-49de-a850-5b8b1d752f63 (admin@gmail.com)
-- =========================================================================

-- (OPTIONAL) SECTION A: Insert Users if not already present
INSERT INTO public.users (id, email, full_name, role, phone_number, department, designation, join_date, manager_id)
VALUES 
  ('a3c8e9b4-d5f1-4c28-98e6-123456789001', 'tanvir@gmail.com', 'Tanvir Rahman', 'manager', '+8801711122233', 'Engineering', 'technicalLead', '2023-01-15', '69d27032-c059-49de-a850-5b8b1d752f63')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.users (id, email, full_name, role, phone_number, department, designation, join_date, manager_id)
VALUES 
  ('b7d9f0e1-a2c3-4d5e-8f6a-123456789002', 'sadia@gmail.com', 'Sadia Islam', 'employee', '+8801822233344', 'Engineering', 'juniorDeveloper', '2024-02-01', 'a3c8e9b4-d5f1-4c28-98e6-123456789001')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.users (id, email, full_name, role, phone_number, department, designation, join_date, manager_id)
VALUES 
  ('c5e7a9f0-d1b2-4c3d-8e5f-123456789003', 'rafiq@gmail.com', 'Rafiqul Alam', 'employee', '+8801933344455', 'Human Resources', 'seniorDeveloper', '2023-06-01', '69d27032-c059-49de-a850-5b8b1d752f63')
ON CONFLICT (id) DO NOTHING;


-- =========================================================================
-- SECTION B: Mock Inserts for Employees (REMOVED id - auto-generated)
-- =========================================================================
INSERT INTO public.employees (
  user_id, first_name, last_name, email, phone_number, address, city, state, zip_code, country, 
  date_of_birth, gender, marital_status, date_of_joining, designation, department, manager, 
  base_salary, allowances, deductions, account_number, bank_name, ifsc_code, pan_number, aadhar_number, 
  emergency_contact, emergency_contact_number, is_active
) VALUES 
  (
    'a3c8e9b4-d5f1-4c28-98e6-123456789001',
    'Tanvir',
    'Rahman',
    'tanvir@gmail.com',
    '+8801711122233',
    'House 42, Road 11, Banani',
    'Dhaka',
    'Dhaka',
    '1213',
    'Bangladesh',
    '1988-08-14',
    'Male',
    'Married',
    '2023-01-15',
    'technicalLead',
    'Engineering',
    '69d27032-c059-49de-a850-5b8b1d752f63',
    120000.00,
    15000.00,
    8000.00,
    '102234567890', 
    'BRAC Bank PLC',
    'BRAC0000001',
    'TIN-123456789',
    'NID-1988123456789',
    'Tahmina Rahman (Wife)',
    '+8801711100099',
    true
  ),
  (
    'b7d9f0e1-a2c3-4d5e-8f6a-123456789002',
    'Sadia',
    'Islam',
    'sadia@gmail.com',
    '+8801822233344',
    'Flat B4, House 10, Road 4, Dhanmondi',
    'Dhaka',
    'Dhaka',
    '1209',
    'Bangladesh',
    '1996-03-22',
    'Female',
    'Single',
    '2024-02-01',
    'juniorDeveloper',
    'Engineering',
    'a3c8e9b4-d5f1-4c28-98e6-123456789001',
    65000.00,
    8000.00,
    3000.00,
    '210456789012', 
    'Dutch-Bangla Bank',
    'DBBL0000210',
    'TIN-987654321',
    'NID-1996223456780',
    'Kamrul Islam (Father)',
    '+8801822200088',
    true
  ),
  (
    'c5e7a9f0-d1b2-4c3d-8e5f-123456789003',
    'Rafiqul',
    'Alam',
    'rafiq@gmail.com',
    '+8801933344455',
    'Sector 4, Road 18, Uttara',
    'Dhaka',
    'Dhaka',
    '1230',
    'Bangladesh',
    '1992-11-05',
    'Male',
    'Married',
    '2023-06-01',
    'seniorDeveloper',
    'Human Resources',
    '69d27032-c059-49de-a850-5b8b1d752f63',
    95000.00,
    12000.00,
    5000.00,
    '01234567899', 
    'Eastern Bank PLC',
    'EBL0000034',
    'TIN-456789123',
    'NID-1992334567891',
    'Jahanara Alam (Mother)',
    '+8801933300077',
    true
  );


-- =========================================================================
-- SECTION C: Mock Inserts for Attendance (with auto-generated IDs)
-- =========================================================================
INSERT INTO public.attendance (
  employee_id, date, check_in_time, check_out_time, status, notes, location, latitude, longitude
) VALUES 
  (
    (SELECT id FROM employees WHERE user_id = 'a3c8e9b4-d5f1-4c28-98e6-123456789001'),
    '2026-07-09',
    '2026-07-09 09:05:00+06',
    '2026-07-09 17:35:00+06',
    'present',
    'Checked in slightly late due to traffic at Mohakhali.',
    'Banani Office',
    23.7937,
    90.4066
  ),
  (
    (SELECT id FROM employees WHERE user_id = 'b7d9f0e1-a2c3-4d5e-8f6a-123456789002'),
    '2026-07-09',
    '2026-07-09 08:55:00+06',
    '2026-07-09 18:00:00+06',
    'present',
    'Normal day.',
    'Banani Office',
    23.7937,
    90.4066
  ),
  (
    (SELECT id FROM employees WHERE user_id = 'b7d9f0e1-a2c3-4d5e-8f6a-123456789002'),
    '2026-07-10',
    NULL,
    NULL,
    'onLeave',
    'Approved casual leave.',
    NULL,
    NULL,
    NULL
  );


-- =========================================================================
-- SECTION D: Mock Inserts for Leave Requests
-- =========================================================================
INSERT INTO public.leave_requests (
  employee_id, leave_type, start_date, end_date, number_of_days, reason, status, approved_by, approved_date, rejection_reason
) VALUES 
  (
    (SELECT id FROM employees WHERE user_id = 'b7d9f0e1-a2c3-4d5e-8f6a-123456789002'),
    'casual',
    '2026-07-10',
    '2026-07-10',
    1,
    'Personal family gathering in Mymensingh.',
    'approved',
    'a3c8e9b4-d5f1-4c28-98e6-123456789001',
    '2026-07-08 14:30:00+06',
    NULL
  ),
  (
    (SELECT id FROM employees WHERE user_id = 'c5e7a9f0-d1b2-4c3d-8e5f-123456789003'),
    'sick',
    '2026-07-13',
    '2026-07-14',
    2,
    'Fever and medical checkup.',
    'pending',
    NULL,
    NULL,
    NULL
  );


-- =========================================================================
-- SECTION E: Mock Inserts for Payroll
-- =========================================================================
INSERT INTO public.payroll (
  employee_id, month, year, base_salary, bonus, deductions, allowances, net_salary, payment_date, payslip_url, transaction_id, is_paid, notes
) VALUES 
  (
    (SELECT id FROM employees WHERE user_id = 'a3c8e9b4-d5f1-4c28-98e6-123456789001'),
    6,
    2026,
    120000.00,
    10000.00,
    8000.00,
    15000.00,
    137000.00,
    '2026-06-30',
    'https://dpwibhfgfxwvxntgjxns.supabase.co/storage/v1/object/public/payslips/tanvir_june_2026.pdf',
    'TXN-BRAC-99210044',
    true,
    'June salary + Eid bonus.'
  ),
  (
    (SELECT id FROM employees WHERE user_id = 'b7d9f0e1-a2c3-4d5e-8f6a-123456789002'),
    6,
    2026,
    65000.00,
    5000.00,
    3000.00,
    8000.00,
    75000.00,
    '2026-06-30',
    'https://dpwibhfgfxwvxntgjxns.supabase.co/storage/v1/object/public/payslips/sadia_june_2026.pdf',
    'TXN-DBBL-77443109',
    true,
    'June salary + Eid bonus.'
  );


-- =========================================================================
-- SECTION F: Mock Inserts for Notifications
-- =========================================================================
INSERT INTO public.notifications (
  user_id, type, title, message, related_id, related_type, data, is_read, read_at
) VALUES 
  (
    'b7d9f0e1-a2c3-4d5e-8f6a-123456789002',
    'leaveApproved',
    'Leave Request Approved',
    'Your Casual Leave request for July 10 has been approved.',
    '11111111-aaaa-bbbb-cccc-123456789001',
    'leave',
    '{"number_of_days": 1, "start_date": "2026-07-10"}'::jsonb,
    false,
    NULL
  ),
  (
    '69d27032-c059-49de-a850-5b8b1d752f63',
    'announcement',
    'Office Dress Code Update',
    'Casual clothing is now permitted on Thursdays and Fridays.',
    NULL,
    'announcement',
    NULL,
    true,
    '2026-07-10 10:00:00+06'
  );


-- =========================================================================
-- SECTION G: Mock Inserts for Holidays
-- =========================================================================
INSERT INTO public.holidays (
  name, date, end_date, is_custom
) VALUES 
  (
    'Independence Day of Bangladesh',
    '2026-03-26',
    NULL,
    false
  ),
  (
    'Eid-ul-Fitr Holiday',
    '2026-03-20',
    '2026-03-22',
    false
  ),
  (
    'Victory Day of Bangladesh',
    '2026-12-16',
    NULL,
    false
  );


-- =========================================================================
-- SECTION H: Mock Inserts for Reports
-- =========================================================================
INSERT INTO public.reports (
  title, description, type, generated_by, status, date_range_start, date_range_end, file_url
) VALUES 
  (
    'June 2026 Attendance Report',
    'Detailed monthly employee checkout metrics and check-in logs.',
    'attendance',
    '69d27032-c059-49de-a850-5b8b1d752f63',
    'generated',
    '2026-06-01',
    '2026-06-30',
    'https://dpwibhfgfxwvxntgjxns.supabase.co/storage/v1/object/public/reports/attendance_june_2026.csv'
  ),
  (
    'Q2 2026 Performance Analytics',
    'Quarterly assessment performance evaluation records.',
    'performance',
    '69d27032-c059-49de-a850-5b8b1d752f63',
    'pending',
    '2026-04-01',
    '2026-06-30',
    NULL
  );


-- =========================================================================
-- SECTION I: Mock Inserts for Performance Reviews
-- =========================================================================
INSERT INTO public.performance_reviews (
  employee_id, reviewed_by, review_year, review_quarter, overall_rating, performance_score, 
  strengths, areas_for_improvement, comments, status, review_date, next_review_date
) VALUES 
  (
    (SELECT id FROM employees WHERE user_id = 'b7d9f0e1-a2c3-4d5e-8f6a-123456789002'),
    'a3c8e9b4-d5f1-4c28-98e6-123456789001',
    2026,
    2,
    4.5,
    90.0,
    'Excellent frontend feature implementation speeds. Quick to learn Riverpod and Flutter layout structures.',
    'Needs to focus on DB schemas and write unit test suites.',
    'Sadia has made massive improvements in Q2. Highly dedicated engineer.',
    'completed',
    '2026-07-05',
    '2026-10-05'
  );