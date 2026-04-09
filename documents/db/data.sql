USE btl_database;
GO

-- ==============================================================================
-- 1. XÓA DỮ LIỆU CŨ VÀ RESET IDENTITY
-- ==============================================================================
DELETE FROM prescription_lines;
DELETE FROM prescriptions;
DELETE FROM procedure_orders;
DELETE FROM payments;
DELETE FROM encounters;
DELETE FROM appointments;
DELETE FROM time_slots;
DELETE FROM patients;
DELETE FROM staffs;
DELETE FROM doctors;
DELETE FROM person_roles;
DELETE FROM persons;
DELETE FROM procedure_catalogs;
DELETE FROM medicines;

DBCC CHECKIDENT ('persons', RESEED, 0);
DBCC CHECKIDENT ('time_slots', RESEED, 0);
DBCC CHECKIDENT ('appointments', RESEED, 0);
DBCC CHECKIDENT ('encounters', RESEED, 0);
DBCC CHECKIDENT ('procedure_catalogs', RESEED, 0);
DBCC CHECKIDENT ('procedure_orders', RESEED, 0);
DBCC CHECKIDENT ('prescriptions', RESEED, 0);
DBCC CHECKIDENT ('medicines', RESEED, 0);
DBCC CHECKIDENT ('payments', RESEED, 0);
GO

-- ==============================================================================
-- 2. INSERT DANH MỤC THỦ THUẬT VÀ THUỐC
-- ==============================================================================
INSERT INTO procedure_catalogs (name, type, description, default_price, is_active) VALUES
(N'Tổng phân tích tế bào máu', 'LAB', N'Phân tích 32 chỉ số máu cơ bản', 150000, 1),
(N'Xét nghiệm sinh hóa máu (Chức năng gan/thận)', 'LAB', N'Đo định lượng AST, ALT, Urea, Creatinine', 350000, 1),
(N'Tổng phân tích nước tiểu', 'LAB', N'Phân tích 10 thông số nước tiểu. Trả kết quả dưới 30 phút.', 80000, 1),
(N'Test nhanh Cúm A/B', 'LAB', N'Lấy dịch tỵ hầu test nhanh.', 150000, 1),
(N'Xét nghiệm đường huyết', 'LAB', N'Đo chỉ số Glucose trong máu lúc đói', 120000, 1),
(N'Siêu âm ổ bụng tổng quát', 'IMAGING', N'Siêu âm khảo sát gan, mật, tụy, lách, thận', 300000, 1),
(N'Siêu âm thai 4D', 'IMAGING', N'Khảo sát hình thái thai nhi 4 chiều', 450000, 1),
(N'Chụp X-quang ngực thẳng', 'IMAGING', N'Chụp X-quang kỹ thuật số tim phổi thẳng', 200000, 1),
(N'Điện tâm đồ (ECG)', 'CARDIO', N'Ghi lại đồ thị hoạt động điện của tim', 150000, 1),
(N'Nội soi Tai Mũi Họng', 'ENT', N'Ống soi mềm có camera thăm khám hốc mũi, vòm họng', 350000, 1),
(N'Khí dung mũi họng', 'ENT', N'Xông thuốc điều trị các bệnh lý đường hô hấp trên', 100000, 1),
(N'Hút rửa mũi trẻ em', 'PEDIATRICS', N'Làm sạch dịch mũi cho bệnh nhi', 100000, 1),
(N'Khám thai định kỳ & Đo Tim thai', 'OBSTETRICS', N'Khám thai kết hợp đo Monitor sản khoa', 250000, 1),
(N'Xét nghiệm Pap Smear', 'OBSTETRICS', N'Phết tế bào cổ tử cung tầm soát ung thư (3-5 ngày có kết quả)', 400000, 1),
(N'Nội soi dạ dày (không gây mê)', 'GENERAL', N'Kiểm tra thực quản, dạ dày (45-60 phút)', 600000, 1);

INSERT INTO medicines (name, strength, unit, is_active) VALUES
('Paracetamol', '500mg', 'tablet', 1),
('Ibuprofen', '400mg', 'tablet', 1),
('Omeprazole', '20mg', 'capsule', 1),
('Esomeprazole', '40mg', 'tablet', 1),
('Domperidone', '10mg', 'tablet', 1),
('Diosmectite (Smecta)', '3g', 'sachet', 1),
('Metformin', '500mg', 'tablet', 1),
('Gliclazide', '30mg', 'tablet', 1),
('Amlodipine', '5mg', 'tablet', 1),
('Losartan', '50mg', 'tablet', 1),
('Rosuvastatin', '10mg', 'tablet', 1),
('Cetirizine', '10mg', 'tablet', 1),
('Amoxicillin + Clavulanate', '875mg/125mg', 'tablet', 1),
('Azithromycin', '250mg', 'tablet', 1),
('Cefuroxime', '500mg', 'tablet', 1),
('Methylprednisolone', '16mg', 'tablet', 1),
('Paracetamol (Siro)', '150mg/5ml', 'bottle', 1),
('Ibuprofen (Siro)', '100mg/5ml', 'bottle', 1),
('Desloratadine (Siro)', '2.5mg/5ml', 'bottle', 1),
('Oresol', '27.9g', 'sachet', 1),
('Bacillus clausii', '2 billion spores/5ml', 'ampoule', 1),
('Saline Nasal Spray', '0.9%', 'bottle', 1),
('Xylometazoline', '0.05%', 'bottle', 1),
('Fluticasone Furoate', '27.5mcg/spray', 'bottle', 1),
('Betadine Gargle', '1%', 'bottle', 1),
('Iron + Folic Acid', '60mg/400mcg', 'tablet', 1),
('Calcium + Vitamin D3', '500mg/200IU', 'tablet', 1),
('Multivitamin (Elevit)', 'Standard', 'tablet', 1),
('Clotrimazole', '100mg', 'suppository', 1),
('Drotaverine (No-spa)', '40mg', 'tablet', 1);
GO

-- ==============================================================================
-- 3. INSERT DỮ LIỆU NHÂN SỰ TĨNH (10 STAFFS, 20 DOCTORS)
-- ==============================================================================
SET IDENTITY_INSERT persons ON;

INSERT INTO persons (person_id, name, dob, sex, tel, address, password) VALUES
(1, N'Nguyễn Thị Thu', '1995-05-12', 'FEMALE', '0912345671', N'Hà Nội', 'staff123'),
(2, N'Lê Văn Nam', '1992-08-23', 'MALE', '0912345672', N'Hà Nội', 'staff123'),
(3, N'Trần Hải Yến', '1998-11-05', 'FEMALE', '0912345673', N'Hà Nội', 'staff123'),
(4, N'Phạm Thị Mai', '1990-02-18', 'FEMALE', '0912345674', N'Hà Nội', 'staff123'),
(5, N'Vũ Đức Thắng', '1988-07-30', 'MALE', '0912345675', N'Hà Nội', 'staff123'),
(6, N'Bùi Xuân Hiếu', '1996-09-14', 'MALE', '0912345676', N'Hà Nội', 'staff123'),
(7, N'Đặng Thị Lan', '1997-04-22', 'FEMALE', '0912345677', N'Hà Nội', 'staff123'),
(8, N'Đỗ Văn Cường', '1993-12-01', 'MALE', '0912345678', N'Hà Nội', 'staff123'),
(9, N'Hồ Minh Ngọc', '1991-06-19', 'MALE', '0912345679', N'Hà Nội', 'staff123'),
(10, N'Ngô Trí Dũng', '1989-10-10', 'MALE', '0912345680', N'Hà Nội', 'staff123'),
(11, N'Nguyễn Tấn Phát', '1975-02-15', 'MALE', '0987654311', N'Hà Nội', 'doctor123'),
(12, N'Trần Thanh Phương', '1982-04-20', 'FEMALE', '0987654312', N'Hà Nội', 'doctor123'),
(13, N'Lê Tuấn Anh', '1985-09-11', 'MALE', '0987654313', N'Hà Nội', 'doctor123'),
(14, N'Phạm Quang Hùng', '1978-11-30', 'MALE', '0987654314', N'Hà Nội', 'doctor123'),
(15, N'Vũ Thị Dung', '1980-05-25', 'FEMALE', '0987654315', N'Hà Nội', 'doctor123'),
(16, N'Bùi Ngọc Lan', '1988-12-14', 'FEMALE', '0987654316', N'Hà Nội', 'doctor123'),
(17, N'Đặng Nhật Minh', '1972-08-08', 'MALE', '0987654317', N'Hà Nội', 'doctor123'),
(18, N'Đỗ Bảo Trâm', '1990-01-22', 'FEMALE', '0987654318', N'Hà Nội', 'doctor123'),
(19, N'Hồ Trung Kiên', '1986-07-19', 'MALE', '0987654319', N'Hà Nội', 'doctor123'),
(20, N'Ngô Thu Hà', '1979-10-05', 'FEMALE', '0987654320', N'Hà Nội', 'doctor123'),
(21, N'Đoàn Văn Hậu', '1983-03-12', 'MALE', '0987654321', N'Hà Nội', 'doctor123'),
(22, N'Đinh Thị Bích', '1987-06-28', 'FEMALE', '0987654322', N'Hà Nội', 'doctor123'),
(23, N'Lý Thái Tổ', '1970-11-15', 'MALE', '0987654323', N'Hà Nội', 'doctor123'),
(24, N'Lê Ngọc Bích', '1989-02-14', 'FEMALE', '0987654324', N'Hà Nội', 'doctor123'),
(25, N'Vũ Đình Trọng', '1984-09-09', 'MALE', '0987654325', N'Hà Nội', 'doctor123'),
(26, N'Trần Văn Khánh', '1976-12-30', 'MALE', '0987654326', N'Hà Nội', 'doctor123'),
(27, N'Bùi Đức Trí', '1981-04-17', 'MALE', '0987654327', N'Hà Nội', 'doctor123'),
(28, N'Nguyễn Quỳnh Hương', '1992-08-23', 'FEMALE', '0987654328', N'Hà Nội', 'doctor123'),
(29, N'Phạm Hồng Minh', '1985-05-05', 'MALE', '0987654329', N'Hà Nội', 'doctor123'),
(30, N'Vũ Duy Tuấn', '1988-10-20', 'MALE', '0987654330', N'Hà Nội', 'doctor123');

SET IDENTITY_INSERT persons OFF;

INSERT INTO person_roles (person_id, role) VALUES
(1, 'STAFF'), (2, 'STAFF'), (3, 'STAFF'), (4, 'STAFF'), (5, 'STAFF'),
(6, 'STAFF'), (7, 'STAFF'), (8, 'STAFF'), (9, 'STAFF'), (10, 'STAFF'),
(11, 'DOCTOR'), (12, 'DOCTOR'), (13, 'DOCTOR'), (14, 'DOCTOR'), (15, 'DOCTOR'),
(16, 'DOCTOR'), (17, 'DOCTOR'), (18, 'DOCTOR'), (19, 'DOCTOR'), (20, 'DOCTOR'),
(21, 'DOCTOR'), (22, 'DOCTOR'), (23, 'DOCTOR'), (24, 'DOCTOR'), (25, 'DOCTOR'),
(26, 'DOCTOR'), (27, 'DOCTOR'), (28, 'DOCTOR'), (29, 'DOCTOR'), (30, 'DOCTOR');

INSERT INTO staffs (s_person_id, workyear_start) VALUES
(1, '2020-01-15'), (2, '2019-03-10'), (3, '2021-06-01'), (4, '2018-09-20'), (5, '2017-11-05'),
(6, '2022-02-14'), (7, '2020-08-08'), (8, '2016-12-12'), (9, '2019-05-25'), (10, '2021-10-10');

INSERT INTO doctors (d_person_id, speciality, level) VALUES
(11, 'General Internal', 'PROFESSOR'),
(12, 'General Internal', 'STANDARD'),
(13, 'General Internal', 'STANDARD'),
(14, 'Obstetrics', 'PROFESSOR'),
(15, 'Obstetrics', 'STANDARD'),
(16, 'Obstetrics', 'STANDARD'),
(17, 'Pediatrics', 'PROFESSOR'),
(18, 'Pediatrics', 'STANDARD'),
(19, 'Pediatrics', 'STANDARD'),
(20, 'ENT', 'PROFESSOR'),
(21, 'ENT', 'STANDARD'),
(22, 'ENT', 'STANDARD'),
(23, 'Laboratory', 'PROFESSOR'),
(24, 'Laboratory', 'STANDARD'),
(25, 'Laboratory', 'STANDARD'),
(26, 'Diagnostic Imaging', 'PROFESSOR'),
(27, 'Diagnostic Imaging', 'STANDARD'),
(28, 'Diagnostic Imaging', 'STANDARD'),
(29, 'General Internal', 'STANDARD'),
(30, 'Pediatrics', 'STANDARD');
GO

-- ==============================================================================
-- 4. SINH DỮ LIỆU ĐỘNG: 800 BỆNH NHÂN VÀ 2000 CA KHÁM
-- ==============================================================================
SET NOCOUNT ON;
PRINT N'Đang khởi tạo 800 Bệnh nhân (Patients)...';

DECLARE @idx INT = 1;
DECLARE @pid INT;

WHILE @idx <= 800
BEGIN
INSERT INTO persons (name, dob, sex, tel, address, password)
VALUES (
N'Bệnh nhân ' + CAST(@idx AS VARCHAR),
DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 25000) - 1000, GETDATE()),
IIF(@idx % 2 = 0, 'MALE', 'FEMALE'),
'09' + RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR), 8),
CASE (ABS(CHECKSUM(NEWID())) % 4)
WHEN 0 THEN N'Hà Nội'
WHEN 1 THEN N'Hà Nam'
WHEN 2 THEN N'Bắc Ninh'
ELSE N'Hưng Yên'
END,
'patient123'
);
SET @pid = SCOPE_IDENTITY();

    INSERT INTO person_roles (person_id, role) VALUES (@pid, 'PATIENT');
    INSERT INTO patients (p_person_id, first_seen) VALUES (@pid, IIF(@idx % 5 = 0, 1, 0));

    SET @idx += 1;

END
PRINT N'Đã khởi tạo xong Bệnh nhân.';

PRINT N'Đang khởi tạo 2000 Lượt khám (Encounters) kèm logic nghiệp vụ. Vui lòng đợi...';

DECLARE @ValidTimes TABLE (ID INT IDENTITY(1,1), H INT, M INT);
INSERT INTO @ValidTimes (H, M) VALUES
(6,0), (6,20), (6,40), (7,0), (7,20), (7,40), (8,0), (8,20), (8,40), (9,0), (9,20), (9,40),
(13,0), (13,20), (13,40), (14,0), (14,20), (14,40), (15,0), (15,20), (15,40);

DECLARE @total_encounters INT = 2000;
DECLARE @current_enc INT = 1;
DECLARE @max_proc_end DATETIME;

WHILE @current_enc <= @total_encounters
BEGIN
DECLARE @rand_patient INT = (SELECT TOP 1 p_person_id FROM patients ORDER BY NEWID());
DECLARE @rand_doctor INT = (SELECT TOP 1 d_person_id FROM doctors ORDER BY NEWID());
DECLARE @doc_spec VARCHAR(30), @doc_level VARCHAR(36);
SELECT @doc_spec = speciality, @doc_level = level FROM doctors WHERE d_person_id = @rand_doctor;

    DECLARE @rand_staff INT = (ABS(CHECKSUM(NEWID())) % 10) + 1;

    DECLARE @rand_days INT = ABS(CHECKSUM(NEWID())) % 455;
    DECLARE @base_date DATE = DATEADD(DAY, @rand_days, '2025-01-01');

    DECLARE @rand_time_id INT = (ABS(CHECKSUM(NEWID())) % 21) + 1;
    DECLARE @h INT, @m INT;
    SELECT @h = H, @m = M FROM @ValidTimes WHERE ID = @rand_time_id;

    DECLARE @slot_start DATETIME = DATETIMEFROMPARTS(YEAR(@base_date), MONTH(@base_date), DAY(@base_date), @h, @m, 0, 0);
    DECLARE @slot_end DATETIME = DATEADD(MINUTE, 20, @slot_start);

    DECLARE @slot_id INT = NULL;
    SELECT @slot_id = slot_id FROM time_slots WHERE d_person_id = @rand_doctor AND start_time = @slot_start;

    IF @slot_id IS NULL
    BEGIN
        DECLARE @is_active INT = IIF(ABS(CHECKSUM(NEWID())) % 100 < 5, 0, 1);
        INSERT INTO time_slots (d_person_id, start_time, end_time, status, is_active)
        VALUES (@rand_doctor, @slot_start, @slot_end, IIF(@is_active=1, 'BOOKED', 'BLOCKED'), @is_active);
        SET @slot_id = SCOPE_IDENTITY();

        IF @is_active = 0 CONTINUE;
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM appointments WHERE p_person_id = @rand_patient AND slot_id = @slot_id)
            CONTINUE;
    END

    DECLARE @rand_status_rate INT = ABS(CHECKSUM(NEWID())) % 100;
    DECLARE @app_status VARCHAR(36) = 'CHECKED_IN';
    IF @rand_status_rate < 5 SET @app_status = 'CANCELLED';
    ELSE IF @rand_status_rate < 10 SET @app_status = 'NO_SHOW';
    ELSE IF @rand_status_rate < 15 SET @app_status = 'BOOKED';

    INSERT INTO appointments (s_person_id, p_person_id, slot_id, status)
    VALUES (@rand_staff, @rand_patient, @slot_id, @app_status);
    DECLARE @app_id INT = SCOPE_IDENTITY();

    IF @app_status <> 'CHECKED_IN' CONTINUE;

    DECLARE @doc_fee DECIMAL(18,0) = IIF(@doc_level = 'PROFESSOR', 500000, 300000);
    DECLARE @enc_start DATETIME = DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % 10, @slot_start);

    -- Khám lâm sàng bước 1
    DECLARE @enc_end DATETIME = DATEADD(MINUTE, 10 + (ABS(CHECKSUM(NEWID())) % 10), @enc_start);

    DECLARE @symptom NVARCHAR(MAX) = N'Đau mỏi chung';
    DECLARE @diagnosis NVARCHAR(MAX) = N'Suy nhược cơ thể';

    IF @doc_spec = 'Pediatrics'
    BEGIN
        SET @symptom = IIF(ABS(CHECKSUM(NEWID())) % 2 = 0, N'Trẻ sốt cao, quấy khóc, ho nhiều', N'Trẻ bị nghẹt mũi, khò khè');
        SET @diagnosis = IIF(ABS(CHECKSUM(NEWID())) % 2 = 0, N'Viêm họng cấp ở trẻ', N'Viêm phế quản');
    END
    ELSE IF @doc_spec = 'Obstetrics'
    BEGIN
        SET @symptom = IIF(ABS(CHECKSUM(NEWID())) % 2 = 0, N'Đến ngày khám thai định kỳ', N'Rối loạn kinh nguyệt, đau bụng dưới');
        SET @diagnosis = IIF(ABS(CHECKSUM(NEWID())) % 2 = 0, N'Thai 16 tuần phát triển bình thường', N'Viêm nhiễm phụ khoa');
    END
    ELSE IF @doc_spec = 'ENT'
    BEGIN
        SET @symptom = N'Đau rát họng, ù tai, nghẹt mũi lâu ngày';
        SET @diagnosis = N'Viêm xoang cấp, Viêm amidan';
    END
    ELSE IF @doc_spec = 'General Internal'
    BEGIN
        SET @symptom = N'Đau đầu, chóng mặt, đo huyết áp ở nhà thấy cao';
        SET @diagnosis = N'Tăng huyết áp vô căn, Rối loạn mỡ máu';
    END

    -- Insert bản ghi encounters tạm thời
    INSERT INTO encounters (app_id, start_time, end_time, symptom, diagnosis, notes, fee)
    VALUES (@app_id, @enc_start, @enc_end, @symptom, @diagnosis, N'Bệnh nhân tuân thủ phác đồ điều trị', @doc_fee);
    DECLARE @enc_id INT = SCOPE_IDENTITY();

    DECLARE @num_procs INT = ABS(CHECKSUM(NEWID())) % 4;
    DECLARE @total_proc_cost DECIMAL(18,0) = 0;

    IF @num_procs > 0
    BEGIN
        INSERT INTO procedure_orders (encounter_id, procedure_id, status, result, start_time, end_time)
        SELECT
            @enc_id, procedure_id, 'COMPLETED',
            CASE (ABS(CHECKSUM(NEWID())) % 3)
                WHEN 0 THEN N'Kết quả nằm trong giới hạn bình thường.'
                WHEN 1 THEN N'Phát hiện dấu hiệu bất thường nhẹ.'
                ELSE N'Kết quả hiển thị viêm nhiễm.'
            END,
            DATEADD(MINUTE, 5 + (ABS(CHECKSUM(NEWID())) % 10), @enc_end) AS start_time,
            CASE
                WHEN procedure_id = 14 THEN DATEADD(DAY, 3 + (ABS(CHECKSUM(NEWID())) % 3), @enc_end)
                WHEN procedure_id IN (10, 15) THEN DATEADD(MINUTE, 45 + (ABS(CHECKSUM(NEWID())) % 15), @enc_end)
                ELSE DATEADD(MINUTE, 15 + (ABS(CHECKSUM(NEWID())) % 15), @enc_end)
            END AS end_time
        FROM (
            SELECT TOP (@num_procs) procedure_id
            FROM procedure_catalogs
            WHERE
                (@doc_spec = 'Pediatrics' AND procedure_id IN (1, 3, 4, 12)) OR
                (@doc_spec = 'Obstetrics' AND procedure_id IN (1, 3, 7, 13, 14)) OR
                (@doc_spec = 'ENT' AND procedure_id IN (10, 11)) OR
                (@doc_spec IN ('General Internal', 'Laboratory', 'Diagnostic Imaging') AND procedure_id IN (1,2,3,5,6,8,9,15))
            ORDER BY NEWID()
        ) T;

        -- Lấy thời gian kết thúc thủ thuật muộn nhất
        SET @max_proc_end = NULL;
        SELECT @max_proc_end = MAX(end_time) FROM procedure_orders WHERE encounter_id = @enc_id;

        IF @max_proc_end IS NOT NULL
        BEGIN
            -- Cập nhật thời gian kết thúc: Cộng thêm 20 đến 90 phút sau khi có kết quả
            SET @enc_end = DATEADD(MINUTE, 20 + (ABS(CHECKSUM(NEWID())) % 71), @max_proc_end);

            UPDATE encounters SET end_time = @enc_end WHERE encounter_id = @enc_id;
        END

        SELECT @total_proc_cost = ISNULL(SUM(default_price), 0)
        FROM procedure_catalogs pc JOIN procedure_orders po ON pc.procedure_id = po.procedure_id
        WHERE po.encounter_id = @enc_id;
    END

    IF (ABS(CHECKSUM(NEWID())) % 100) < 75
    BEGIN
        INSERT INTO prescriptions (encounter_id, title)
        VALUES (@enc_id, N'Đơn thuốc của bác sĩ ' + (SELECT name FROM persons WHERE person_id = @rand_doctor));
        DECLARE @pres_id INT = SCOPE_IDENTITY();

        DECLARE @num_meds INT = (ABS(CHECKSUM(NEWID())) % 4) + 1;

        INSERT INTO prescription_lines (prescription_id, medicine_id, dosage, quantity)
        SELECT
            @pres_id, medicine_id,
            CASE (ABS(CHECKSUM(NEWID())) % 3)
                WHEN 0 THEN N'Sáng 1 - Tối 1'
                WHEN 1 THEN N'Ngày uống 1 lần'
                ELSE N'Dùng khi đau/sốt'
            END,
            (ABS(CHECKSUM(NEWID())) % 10) + 10
        FROM (
            SELECT TOP (@num_meds) medicine_id, unit
            FROM medicines
            WHERE
                (@doc_spec = 'Pediatrics' AND medicine_id IN (6, 17, 18, 19, 20, 21, 22, 23)) OR
                (@doc_spec = 'Obstetrics' AND medicine_id IN (1, 26, 27, 28, 29, 30)) OR
                (@doc_spec = 'ENT' AND medicine_id IN (1, 2, 12, 13, 14, 15, 16, 22, 24, 25)) OR
                (@doc_spec IN ('General Internal', 'Laboratory', 'Diagnostic Imaging') AND medicine_id IN (1,2,3,4,5,7,8,9,10,11))
            ORDER BY NEWID()
        ) T;
    END

    DECLARE @pay_method VARCHAR(36) =
        CASE (ABS(CHECKSUM(NEWID())) % 3)
            WHEN 0 THEN 'CASH'
            WHEN 1 THEN 'CARD'
            ELSE 'EWALLET'
        END;

    INSERT INTO payments (encounter_id, s_person_id, amount, method, pay_time)
    VALUES (@enc_id, @rand_staff, @doc_fee + @total_proc_cost, @pay_method, @enc_end);

    SET @current_enc += 1;

END

PRINT N'✅ HOÀN TẤT! Đã sinh thành công 2000 lượt khám, đơn thuốc, thủ thuật và giao dịch.';
SET NOCOUNT OFF;
GO
