### 2.1. Mô tả nghiệp vụ chi tiết

#### 2.1.1. Luồng khám bệnh chi tiết

Quy trình khám chữa bệnh tại hệ thống được chia thành 2 kịch bản (đặt lịch trước và không đặt lịch).

**A. Giai đoạn Tiếp đón & Khởi tạo hồ sơ**

- **Kịch bản 1: Bệnh nhân đã đặt lịch trước (Pre-booked)**
  1.  **Đăng ký/Đặt lịch:** Bệnh nhân truy cập hệ thống Web, đăng ký hoặc cập nhật hồ sơ cá nhân. Bệnh nhân tra cứu thông tin bác sĩ, chuyên khoa và chọn khung giờ khám (Time Slot) còn trống.
  2.  **Quy tắc xếp lịch:** Mỗi khung giờ (Time Slot) kéo dài 20 phút. Hệ thống giới hạn tối đa 2 bệnh nhân đặt lịch cho mỗi khung giờ này. Ngay khi đặt thành công, hệ thống cấp cho bệnh nhân một **Số thứ tự (STT) cố định** của khung giờ đó. Bệnh nhân có quyền hủy hoặc thay đổi lịch hẹn bất cứ lúc nào. Lịch hẹn sẽ tự động hủy nếu trong ngày bệnh nhân không đến khám.
  3.  **Check-in:** Khi bệnh nhân đến phòng khám, nhân viên hành chính tra cứu lịch hẹn trên hệ thống.
  4.  **Đặc quyền STT:** Nếu bệnh nhân đến đúng giờ hoặc đến muộn hơn thời gian hẹn, hệ thống vẫn bảo lưu đúng STT cố định đã cấp. Bệnh nhân chỉ cần đợi bệnh nhân hiện tại trong phòng khám xong là sẽ được ưu tiên vào ngay theo STT bảo lưu đó.
  5.  **Thu ngân ban đầu:** Nhân viên tiến hành thu tiền khám lâm sàng ban đầu (phí khám phụ thuộc vào cấp bậc bác sĩ: STANDARD hoặc PROFESSOR). Sau khi thu tiền, trạng thái lịch hẹn chuyển sang `CHECKED_IN`, hệ thống tự động khởi tạo hồ sơ lượt khám (`Encounter`) gắn với lịch hẹn này.

- **Kịch bản 2: Bệnh nhân đến trực tiếp (Walk-in)**
  1.  **Lấy số tại quầy:** Bệnh nhân đến trực tiếp quầy lễ tân. Nhân viên hành chính hỗ trợ tạo mới hoặc cập nhật hồ sơ (nếu là bệnh nhân cũ).
  2.  **Xếp lịch linh hoạt:** Nhân viên kiểm tra các khung giờ của bác sĩ chuyên khoa tương ứng. Nếu có khung giờ của 1 bác sỹ chưa đủ người thì sẽ sắp xếp khung giờ gần nhất cho bệnh nhân (1 Time Slot tối đa 3 bệnh nhân).
  3.  **Cấp STT & Thu ngân:** Bệnh nhân được cấp một STT mới (xếp sau các bệnh nhân đã đặt lịch trước trong cùng khung giờ). Nhân viên thu phí khám ban đầu, hệ thống tạo lượt khám (`Encounter`) và hướng dẫn bệnh nhân đến phòng khám.

**B. Giai đoạn Khám lâm sàng & Chỉ định cận lâm sàng**

- **Khám bệnh:** Theo STT, bệnh nhân vào phòng khám. Bác sĩ mở hồ sơ `Encounter`, ghi nhận các triệu chứng (symptom) và đưa ra chẩn đoán sơ bộ (diagnosis).
- **Chỉ định dịch vụ:** Nếu cần thiết, bác sĩ tạo các chỉ định thủ thuật/xét nghiệm (Procedure Orders). Trạng thái của các chỉ định này lúc này là `REQUESTED` (Chờ thanh toán).

**C. Giai đoạn Thanh toán thủ thuật & Thực hiện**

- **Thanh toán:** Bệnh nhân cầm phiếu chỉ định ra quầy thu ngân. Nhân viên tính tổng tiền dựa trên giá mặc định (`default_price`) của từng thủ thuật.
- **Xuất hóa đơn:** Bệnh nhân thanh toán. Giao dịch (`Payment`) được hệ thống lưu lại, trạng thái các thủ thuật tự động cập nhật thành `IN_PROGRESS` (Đang thực hiện).
- **Thực hiện cận lâm sàng:** Bệnh nhân di chuyển lần lượt đến các phòng chuyên môn (Lấy máu, Siêu âm, X-Quang...). Các kỹ thuật viên thực hiện và cập nhật kết quả (Result) lên hệ thống.

**D. Giai đoạn Kết luận & Kê đơn**

- Bệnh nhân quay lại phòng khám ban đầu.
- Bác sĩ xem kết quả xét nghiệm/thủ thuật trực tiếp trên hệ thống, cập nhật kết luận cuối cùng (Notes).
- Bác sĩ kê toa thuốc (`Prescription`) gồm các loại thuốc, liều lượng và số lượng cụ thể, dặn dò bệnh nhân và kết thúc lượt khám.

**E. Giai đoạn Quản lý & Thống kê**

- Dữ liệu từ toàn bộ các luồng trên được lưu trữ để Ban giám đốc/Quản lý truy xuất các báo cáo: Doanh thu theo ngày/tháng, tỷ lệ đúng hẹn, hiệu suất khám của bác sĩ,...

---

#### 2.1.2. Chi tiết thông tin quy mô bệnh viện, danh mục thủ thuật và các loại thuốc được kê

Với quy mô là một Bệnh viện tư nhân cỡ vừa / Phòng khám đa khoa lớn, hệ thống sẽ bao gồm **6 khoa thiết yếu** sau đây để đáp ứng nhu cầu khám chữa bệnh cơ bản và phổ biến nhất của người dân:

1.  **Khoa Khám bệnh & Nội tổng hợp** (General Internal Medicine): Đây là nơi tiếp nhận bệnh nhân ban đầu, khám các bệnh lý thường gặp (như cao huyết áp, dạ dày, tiểu đường, cảm cúm). Bác sĩ sẽ chẩn đoán và kê đơn thuốc để bệnh nhân mang về nhà tự điều trị.
2.  **Khoa Sản phụ khoa** (Obstetrics & Gynecology): Chức năng chính là theo dõi thai kỳ (siêu âm, đo tim thai), khám và điều trị các viêm nhiễm phụ khoa thông thường, hoặc tầm soát ung thư.
3.  **Khoa Nhi** (Pediatrics): Chuyên khám các bệnh lý hô hấp, tiêu hóa cho trẻ em, hoặc tư vấn dinh dưỡng. Các bác sĩ Nhi sẽ kê đơn liều lượng phù hợp cho trẻ mang về.
4.  **Khoa Tai Mũi Họng** (Otorhinolaryngology / ENT): Khám, nội soi tai mũi họng, và thực hiện các thủ thuật xử lý tại chỗ ngay trên ghế khám (như lấy ráy tai, hút rửa mũi, khí dung) rồi cho bệnh nhân ra về.
5.  **Khoa Xét nghiệm** (Laboratory): Nhận mẫu máu, nước tiểu, dịch tiết ngay tại phòng khám để phân tích bằng máy. Đặc thù của ngoại trú là phải trả kết quả nhanh (thường trong ngày hoặc trong vài giờ) để bác sĩ kịp kết luận.
6.  **Khoa Chẩn đoán hình ảnh** (Diagnostic Imaging): Thực hiện X-quang, Siêu âm, Điện tim. Bệnh nhân làm xong sẽ nhận kết quả gửi về phòng khám ban đầu.

##### Danh mục thủ thuật (Procedure Catalog):

| Tên thủ thuật (Name)                             | Phân loại (Type)      | Mô tả chi tiết (Description)                                                                                                                         | Giá tiền (Default Price - VNĐ) |
| :----------------------------------------------- | :-------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------- |
| **Tổng phân tích tế bào máu**                    | LAB (Xét nghiệm)      | Lấy máu tĩnh mạch, phân tích 32 chỉ số máu cơ bản (hồng cầu, bạch cầu, tiểu cầu). Phục vụ chẩn đoán viêm nhiễm, thiếu máu.                           | 150.000                        |
| **Xét nghiệm sinh hóa máu (Chức năng gan/thận)** | LAB (Xét nghiệm)      | Đo định lượng AST, ALT, Urea, Creatinine trong máu. Đánh giá chức năng gan và thận.                                                                  | 350.000                        |
| **Tổng phân tích nước tiểu**                     | LAB (Xét nghiệm)      | Phân tích 10 thông số nước tiểu. Trả kết quả rất nhanh (thường dưới 30 phút).                                                                        | 80.000                         |
| **Test nhanh Cúm A/B**                           | LAB (Xét nghiệm)      | Lấy dịch tỵ hầu test nhanh. Dịch vụ này cực kỳ phổ biến ở phòng khám ngoại trú.                                                                      | 150.000                        |
| **Xét nghiệm đường huyết**                       | LAB (Xét nghiệm)      | Đo chỉ số Glucose trong máu lúc đói để chẩn đoán và theo dõi bệnh tiểu đường.                                                                        | 120.000                        |
| **Siêu âm ổ bụng tổng quát**                     | IMAGING (CĐ Hình ảnh) | Siêu âm khảo sát các tạng trong ổ bụng: gan, mật, tụy, lách, thận, bàng quang.                                                                       | 300.000                        |
| **Siêu âm thai 4D**                              | IMAGING (CĐ Hình ảnh) | Khảo sát hình thái thai nhi 4 chiều dành cho Khoa Sản. Phát hiện dị tật thai nhi.                                                                    | 450.000                        |
| **Chụp X-quang ngực thẳng**                      | IMAGING (CĐ Hình ảnh) | Chụp X-quang kỹ thuật số tim phổi thẳng. Hỗ trợ chẩn đoán bệnh lý hô hấp.                                                                            | 200.000                        |
| **Điện tâm đồ (ECG)**                            | CARDIO (Tim mạch)     | Ghi lại đồ thị hoạt động điện của tim. Hỗ trợ chẩn đoán rối loạn nhịp tim.                                                                           | 150.000                        |
| **Nội soi Tai Mũi Họng**                         | ENT (Tai Mũi Họng)    | Sử dụng ống soi mềm có camera thăm khám chi tiết hốc mũi, vòm họng, thanh quản.                                                                      | 350.000                        |
| **Khí dung mũi họng**                            | ENT (Tai Mũi Họng)    | Xông thuốc điều trị các bệnh lý đường hô hấp trên bằng máy khí dung.                                                                                 | 100.000                        |
| **Hút rửa mũi trẻ em**                           | PEDIATRICS (Nhi khoa) | Thủ thuật làm sạch dịch mũi cho bệnh nhi tại Khoa Nhi. (Không cần thời gian chờ kết quả vì làm xong là kết thúc).                                    | 100.000                        |
| **Khám thai định kỳ & Đo Tim thai**              | OBSTETRICS (Sản khoa) | Khám thai kết hợp đo Monitor sản khoa theo dõi tim thai và cơn gò tử cung.                                                                           | 250.000                        |
| **Xét nghiệm Pap Smear**                         | OBSTETRICS (Sản khoa) | Phết tế bào cổ tử cung để tầm soát ung thư. **Lưu ý:** Thủ thuật này thường mất 3-5 ngày mới có kết quả (rất tốt để làm data cho thời gian chờ lâu). | 400.000                        |
| **Nội soi dạ dày (không gây mê)**                | GENERAL               | Sử dụng ống soi mềm kiểm tra thực quản, dạ dày. Thời gian thực hiện và chờ kết quả mức độ trung bình (khoảng 45 - 60 phút).                          | 600.000                        |

Với mô hình phòng khám đa khoa ngoại trú, việc kê đơn thuốc sẽ chủ yếu diễn ra ở 4 khoa lâm sàng: **Khoa Khám bệnh & Nội tổng hợp, Khoa Nhi, Khoa Sản phụ khoa, và Khoa Tai Mũi Họng**. (Hai khoa Cận lâm sàng là Xét nghiệm và Chẩn đoán hình ảnh thường chỉ trả kết quả, hiếm khi trực tiếp kê đơn mang về).

Dưới đây là danh mục thuốc thật đầy đủ và tiêu biểu nhất cho mô hình ngoại trú, được tổng hợp dựa trên các mặt bệnh phổ biến mà 4 khoa trên thường xuyên tiếp nhận. Dữ liệu này rất lý tưởng để bạn `INSERT` vào bảng `medicines` làm dữ liệu giả (synthetic data) cho Data Warehouse.

##### Danh mục thuốc (Medicines Catalog):

| Name (Tên thuốc)                 | Strength (Liều lượng/Nồng độ) | Unit (Đơn vị đóng gói) | Is_active | Nhóm / Khoa thường kê (Ghi chú thêm)               |
| :------------------------------- | :---------------------------- | :--------------------- | :-------- | :------------------------------------------------- |
| Paracetamol                      | 500mg                         | tablet                 | TRUE      | Giảm đau, hạ sốt (Nội, Sản, TMH)                   |
| Ibuprofen                        | 400mg                         | tablet                 | TRUE      | Kháng viêm, giảm đau (Nội, TMH)                    |
| Omeprazole                       | 20mg                          | capsule                | TRUE      | Dạ dày, trào ngược (Nội)                           |
| Esomeprazole                     | 40mg                          | tablet                 | TRUE      | Viêm loét dạ dày (Nội)                             |
| Domperidone                      | 10mg                          | tablet                 | TRUE      | Chống nôn (Nội)                                    |
| Diosmectite (Smecta)             | 3g                            | sachet                 | TRUE      | Tiêu chảy (Nội, Nhi)                               |
| Metformin                        | 500mg                         | tablet                 | TRUE      | Tiểu đường (Nội)                                   |
| Gliclazide                       | 30mg                          | tablet                 | TRUE      | Tiểu đường (Nội)                                   |
| Amlodipine                       | 5mg                           | tablet                 | TRUE      | Huyết áp cao (Nội)                                 |
| Losartan                         | 50mg                          | tablet                 | TRUE      | Huyết áp cao (Nội)                                 |
| Rosuvastatin                     | 10mg                          | tablet                 | TRUE      | Mỡ máu (Nội)                                       |
| Cetirizine                       | 10mg                          | tablet                 | TRUE      | Dị ứng (Nội, TMH)                                  |
| Amoxicillin + Clavulanate        | 875mg/125mg                   | tablet                 | TRUE      | Kháng sinh phổ rộng (Nội, TMH)                     |
| Azithromycin                     | 250mg                         | tablet                 | TRUE      | Kháng sinh hô hấp (Nội, TMH)                       |
| Cefuroxime                       | 500mg                         | tablet                 | TRUE      | Kháng sinh (Nội, TMH)                              |
| Methylprednisolone               | 16mg                          | tablet                 | TRUE      | Corticoid kháng viêm mạnh (TMH, Nội)               |
| Paracetamol (Siro)               | 150mg/5ml                     | bottle                 | TRUE      | Hạ sốt cho trẻ em (Nhi)                            |
| Ibuprofen (Siro)                 | 100mg/5ml                     | bottle                 | TRUE      | Kháng viêm cho trẻ em (Nhi)                        |
| Desloratadine (Siro)             | 2.5mg/5ml                     | bottle                 | TRUE      | Dị ứng, sổ mũi trẻ em (Nhi)                        |
| Oresol                           | 27.9g                         | sachet                 | TRUE      | Bù nước, điện giải (Nhi, Nội)                      |
| Bacillus clausii (Enterogermina) | 2 billion spores/5ml          | ampoule                | TRUE      | Men vi sinh tiêu hóa (Nhi, Nội)                    |
| Saline Nasal Spray (Nước muối)   | 0.9%                          | bottle                 | TRUE      | Xịt rửa mũi (TMH, Nhi)                             |
| Xylometazoline (Otrivin)         | 0.05%                         | bottle                 | TRUE      | Nhỏ mũi chống nghẹt cho trẻ (Nhi, TMH)             |
| Fluticasone Furoate (Avamys)     | 27.5mcg/spray                 | bottle                 | TRUE      | Xịt mũi corticoid trị viêm xoang (TMH)             |
| Betadine Gargle                  | 1%                            | bottle                 | TRUE      | Súc họng sát khuẩn (TMH)                           |
| Iron + Folic Acid                | 60mg/400mcg                   | tablet                 | TRUE      | Bổ sung sắt cho bà bầu (Sản phụ khoa)              |
| Calcium + Vitamin D3             | 500mg/200IU                   | tablet                 | TRUE      | Bổ sung canxi (Sản phụ khoa, Nội)                  |
| Multivitamin (Elevit / Obimin)   | Standard                      | tablet                 | TRUE      | Vitamin tổng hợp cho thai phụ (Sản phụ khoa)       |
| Clotrimazole                     | 100mg                         | suppository            | TRUE      | Viên đặt âm đạo trị nấm (Sản phụ khoa)             |
| Drotaverine (No-spa)             | 40mg                          | tablet                 | TRUE      | Giảm co thắt cơ trơn, đau bụng kinh (Sản phụ khoa) |
