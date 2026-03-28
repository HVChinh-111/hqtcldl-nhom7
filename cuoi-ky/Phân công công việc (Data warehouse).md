### Phân tích sơ bộ Kho dữ liệu (Data Warehouse) cần có
Trước khi chia việc, cả nhóm cần thống nhất kiến trúc Lược đồ hình sao (Star Schema) cho 2 báo cáo này:
* **Các bảng Chiều (Dimension Tables):** `Dim_Date` (Bắt buộc phải có để phân tích theo tháng/quý/năm), `Dim_Doctor` (Phân tích theo bác sĩ), `Dim_Procedure` (Phân tích theo thủ thuật).
* **Bảng Sự kiện 1 (Fact_Revenue):** Phục vụ Báo cáo 1. Chứa các chỉ số về doanh thu (Tiền khám, Tiền thủ thuật).
* **Bảng Sự kiện 2 (Fact_Procedure_Performance):** Phục vụ Báo cáo 2. Chứa các chỉ số về thời gian (Thời gian bắt đầu, kết thúc, tổng thời gian chờ).

---

### Bảng Phân Công Công Việc (Dành cho 3 thành viên)

**1. Đăng: Data Architect & Dimension Lead (Kiến trúc sư Dữ liệu)**
* **Vai trò:** Người cầm trịch cấu trúc tổng thể và chuẩn bị các bảng danh mục.
* **Nhiệm vụ cụ thể:**
    * Thiết kế bản vẽ Star Schema hoàn chỉnh trên giấy hoặc công cụ vẽ (như draw.io) kết nối các Fact và Dim.
    * Viết script SQL (DDL) để tạo các bảng `Dim_Date`, `Dim_Doctor`, `Dim_Procedure` trong Data Warehouse.
    * **Đặc biệt:** Viết script tự động sinh dữ liệu cho bảng `Dim_Date` (tạo ra các dòng dữ liệu cho từng ngày, tháng, quý, năm từ 2024 đến 2030).
    * Review chéo code SQL của Thành viên B và C để đảm bảo các khóa ngoại (Foreign Keys) khớp với nhau.

**2. Hiền: Data Engineer - Mảng Doanh thu (ETL Fact Revenue)**
* **Vai trò:** Xử lý luồng dữ liệu tiền bạc phục vụ Báo cáo 1.
* **Nhiệm vụ cụ thể:**
    * Viết code tạo bảng `Fact_Revenue`.
    * Xây dựng script ETL (có thể dùng SQL Stored Procedure) để trích xuất dữ liệu từ các bảng OLTP: `payments`, `encounters`, `procedure_orders`.
    * *Thử thách Transform:* Phải bóc tách được doanh thu nào là tiền công khám của bác sĩ (từ `encounters.fee`), doanh thu nào là từ thủ thuật (từ `procedure_catalogs.default_price`), sau đó nạp vào `Fact_Revenue` kèm theo thời gian thanh toán.

**3. Biên: Data Engineer - Mảng Hiệu suất & BI (ETL Fact Performance & Power BI)**
* **Vai trò:** Xử lý luồng dữ liệu thời gian phục vụ Báo cáo 2 và chịu trách nhiệm trực quan hóa.
* **Nhiệm vụ cụ thể:**
    * Viết code tạo bảng `Fact_Procedure_Performance`.
    * Xây dựng script ETL trích xuất từ bảng `procedure_orders`. 
    * *Thử thách Transform:* Dùng hàm DATEDIFF trong SQL Server để tính toán khoảng thời gian giữa `end_time` và `start_time` ra số phút (Turnaround Time), sau đó nạp vào Fact.
    * Kết nối Power BI vào Data Warehouse vừa tạo, kéo thả thử các biểu đồ để kiểm tra xem cấu trúc dữ liệu A, B làm đã đáp ứng được việc vẽ chart chưa.

---

### Lộ trình thực hiện (Timeline 1 Tuần)

* **Ngày 1: Họp Kick-off & Chốt cấu trúc (Làm chung)** Deadline: 21h 31/03 họp.
    * Cả 3 người ngồi lại chốt các trường dữ liệu (columns) sẽ có trong các bảng Dim và Fact. Thống nhất kiểu dữ liệu (INT, DATETIME, DECIMAL) để code không bị lệch pha.
* **Ngày 2 - Ngày 4: Xây dựng và ETL (Làm song song)**
    * Thành viên A code xong và đổ dữ liệu vào các bảng `Dim`.
    * Thành viên B và C bắt tay viết các câu lệnh `SELECT` phức tạp từ CSDL gốc (có `JOIN` các bảng) để chuẩn bị cho việc nạp dữ liệu (Load) vào bảng `Fact`.
* **Ngày 5: Tích hợp & Chạy thử (Integration)**
    * Chạy toàn bộ quy trình: Từ tạo bảng -> Nạp dữ liệu Dim -> Nạp dữ liệu Fact. 
    * Cả nhóm check lại xem dữ liệu doanh thu có bị nhân đôi không, dữ liệu thời gian thủ thuật có bị âm (do start_time > end_time) hay không để quay lại bước làm sạch dữ liệu.
* **Ngày 6: Lên hình Power BI (Thành viên C chủ trì)**
    * Thành viên C kéo dữ liệu lên Power BI, tạo các biểu đồ tăng trưởng (Line chart cho doanh thu, Bar chart cho thời gian thủ thuật). A và B hỗ trợ viết các hàm DAX (nếu cần tính toán phức tạp thêm trên Power BI).
* **Ngày 7: Hoàn thiện Báo cáo Word**
    * Chụp ảnh màn hình các bảng trong DWH, chụp ảnh sơ đồ Star Schema, chụp ảnh Dashboard trên Power BI và đóng gói vào chương 4, 5, 6 của file báo cáo.

Công việc căng nhất sẽ rơi vào khâu **Transform (Biến đổi dữ liệu)** của Thành viên B và C. Bạn có muốn tôi giúp viết nháp cấu trúc bảng (Lệnh `CREATE TABLE`) cho `Fact_Revenue` và `Fact_Procedure_Performance` để nhóm bạn dễ hình dung cách lưu trữ không?