 
# Data Warehouse Roadmap (Level-based) — Làm được dự án end-to-end (Domain: E-commerce)

## Mục lục (TOC)
- [0) Tổng quan: Data Warehouse là gì và dùng để làm gì?](#0-tổng-quan-data-warehouse-là-gì-và-dùng-để-làm-gì)
- [1) Level 1 — Nền tảng tư duy Analytics & mô hình dữ liệu](#1-level-1--nền-tảng-tư-duy-analytics--mô-hình-dữ-liệu)
- [2) Level 2 — Star Schema, Snowflake và quy trình Kimball (thực dụng)](#2-level-2--star-schema-snowflake-và-quy-trình-kimball-thực-dụng)
- [3) Level 3 — Slowly Changing Dimensions (SCD) và lịch sử dữ liệu](#3-level-3--slowly-changing-dimensions-scd-và-lịch-sử-dữ-liệu)
- [4) Level 4 — ETL/ELT và pipeline nạp dữ liệu (project-ready)](#4-level-4--etlelts-và-pipeline-nạp-dữ-liệu-project-ready)
- [5) Level 5 — Data Quality, Testing và Observability](#5-level-5--data-quality-testing-và-observability)
- [6) Level 6 — Hiệu năng truy vấn và tối ưu chi phí](#6-level-6--hiệu-năng-truy-vấn-và-tối-ưu-chi-phí)
- [7) Level 7 — Semantic Layer, Metrics và “Single Definition of Truth”](#7-level-7--semantic-layer-metrics-và-single-definition-of-truth)
- [8) Level 8 — Governance, Security và vận hành production](#8-level-8--governance-security-và-vận-hành-production)
- [9) Level 9 — Nâng cao: pattern và kiến trúc hiện đại](#9-level-9--nâng-cao-pattern-và-kiến-trúc-hiện-đại)
- [10) Capstone Project — Dự án DW end-to-end (bắt buộc)](#10-capstone-project--dự-án-dw-end-to-end-bắt-buộc)

---

## Domain xuyên suốt: E-commerce (bối cảnh dữ liệu)
Ta giả lập một sàn bán hàng online. Khách hàng đặt đơn, thanh toán, giao hàng; sản phẩm có giá và nhóm hàng; khách hàng có địa chỉ và hạng (tier). Mục tiêu của DW là trả lời “Doanh thu hôm nay là bao nhiêu?”, “Sản phẩm nào bán chạy theo tuần?”, “Khách hạng Gold có hành vi mua ra sao?” một cách nhất quán và có thể kiểm toán.

---

## 0) Tổng quan: Data Warehouse là gì và dùng để làm gì?

### Mục tiêu level
Bạn hiểu DW như “hệ thống sự thật dùng chung” cho phân tích, và biết nó đứng ở đâu trong kiến trúc dữ liệu doanh nghiệp.

### DW trong góc nhìn doanh nghiệp
Data Warehouse (DW) là nơi tổ chức dữ liệu để phục vụ báo cáo/analytics ổn định, nhất quán, có lịch sử và có định nghĩa rõ ràng. Điểm cốt lõi là “single source of truth”: cùng một câu hỏi (ví dụ doanh thu) thì mọi team trả lời ra cùng một con số, vì họ cùng dùng một mô hình và một định nghĩa metric.

OLTP (hệ thống giao dịch) tối ưu cho ghi/đọc nhanh từng đơn, từng khách; dữ liệu thường “hiện tại”, và cấu trúc bám ứng dụng. DW tối ưu cho truy vấn phân tích trên khối lượng lớn theo thời gian, chấp nhận “denormalize có kiểm soát” để join nhanh và dễ hiểu.

### DW vs OLTP vs Data Lake vs Lakehouse (ngắn gọn, thực dụng)
OLTP là nơi phát sinh giao dịch (orders, payments…), thay đổi liên tục và ưu tiên tính đúng của từng record. DW là nơi tổng hợp và chuẩn hóa để phân tích, ưu tiên tính nhất quán và lịch sử.

Data Lake thường là nơi chứa dữ liệu thô (raw) đa định dạng với ít ràng buộc hơn, dễ “đổ vào trước, nghĩ sau”. Lakehouse là hướng hợp nhất trải nghiệm lake + khả năng quản trị/SQL/hiệu năng kiểu warehouse. Trong đồ án, bạn có thể xem “raw/staging” như lake layer, còn “core/marts/semantic” như warehouse layer, miễn là ranh giới trách nhiệm rõ.

### Kiến trúc tổng quan (nguồn → staging/raw → transform → marts/semantic → BI)
Một kiến trúc dễ làm dự án là phân tầng theo mục đích, để lỗi ở tầng nào thì xử ở tầng đó, không “vá” trên dashboard.

```

[OLTP Sources] -> [Ingest] -> [Staging/Raw] -> [Transform/Core] -> [Marts/Semantic] -> [BI/Analytics]
orders         batch        raw_orders        fact/dim           metrics layer        dashboards
payments       CDC?         raw_payments      conformed dims      consistent KPIs      ad-hoc SQL

````

### Lỗi hay gặp
Lỗi phổ biến là dùng thẳng OLTP để làm báo cáo, rồi đến lúc dữ liệu lớn lên thì dashboard chậm, số liệu lệch và không ai chịu trách nhiệm định nghĩa. Một lỗi khác là “gom hết vào một bảng to”, nhìn nhanh thì tiện nhưng rất khó mở rộng, khó kiểm toán, và dễ mâu thuẫn định nghĩa.

### Checklist áp dụng
- [ ] Bạn nói được DW dùng để làm gì trong doanh nghiệp: báo cáo nhất quán + lịch sử + kiểm toán được  
- [ ] Bạn phác được luồng dữ liệu tối thiểu từ nguồn đến BI theo các tầng mục đích  
- [ ] Bạn phân biệt được: OLTP (giao dịch) vs DW (phân tích) bằng 1–2 ví dụ cụ thể  

---

## 1) Level 1 — Nền tảng tư duy Analytics & mô hình dữ liệu

### Mục tiêu level
Bạn nắm 5 khái niệm “sống còn” (fact/dim/grain/measures/surrogate key) và thiết kế được một star cơ bản cho bài toán doanh thu.

### Khái niệm cốt lõi (gắn với việc làm dự án)
**Fact** là bảng ghi lại “sự kiện đo lường được” theo một grain rõ ràng. Trong e-commerce, sự kiện phổ biến là “một dòng sản phẩm trong một đơn hàng” vì nó chứa số lượng và giá tại thời điểm mua.

**Dimension** là bảng mô tả ngữ cảnh để cắt lát sự kiện: ngày, sản phẩm, khách hàng… Dimension giúp bạn trả lời “doanh thu theo cái gì”. Nếu fact trả lời “bao nhiêu”, dim trả lời “của ai/cái gì/khi nào/ở đâu”.

**Grain** là “một dòng trong fact đại diện cho cái gì”. Đây là mấu chốt: grain sai thì mọi metric sai, join sai, và bạn sẽ sửa mãi không hết. Nguyên tắc thực dụng là: quyết grain trước, mọi thứ sau.

**Measures** là các số đo trong fact (qty, gross_amount, discount_amount, net_amount…). Điều quan trọng là mỗi measure phải có định nghĩa rõ (đã trừ hoàn/huỷ chưa? đã trừ thuế chưa?).

**Surrogate key** là khóa thay thế do DW tạo (ví dụ customer_key), dùng để ổn định join và hỗ trợ lưu lịch sử (SCD). Bạn không “đặt cược” vào khóa tự nhiên từ OLTP vì nó có thể đổi, trùng, hoặc có logic phức tạp.

### Trực giác “grain trước, mọi thứ sau”
Nếu bạn chọn grain là “1 order” nhưng lại muốn phân tích theo sản phẩm, bạn sẽ bí: một order có nhiều sản phẩm, thế doanh thu theo sản phẩm lấy ở đâu ra? Ngược lại, chọn grain là “1 order line” thì bạn vẫn tổng hợp lên mức order được, nhưng không mất khả năng phân tích chi tiết.

Trong dự án, hãy viết ra câu: “1 dòng của fact_sales đại diện cho …” và kiểm tra nó có duy nhất, có thể đếm được, và có thể tái dựng từ nguồn hay không. Nếu câu đó mập mờ, bạn chưa sẵn sàng thiết kế.

### Ví dụ thiết kế cơ bản (e-commerce)
Giả lập nguồn OLTP:
- `orders(order_id, customer_id, order_ts, status, ...)`
- `order_items(order_id, product_id, quantity, unit_price, discount, ...)`
- `products(product_id, sku, name, category, ...)`
- `customers(customer_id, email, name, address, tier, ...)`

Thiết kế DW tối thiểu:
- `dim_date(date_key, date, day, month, year, week, ...)`
- `dim_product(product_key, product_id, sku, name, category, ...)`
- `dim_customer(customer_key, customer_id, email, name, address, tier, ...)`
- `fact_sales(grain = 1 row = 1 order_item)`
  - keys: `date_key, product_key, customer_key`
  - degenerate: `order_id` (giữ như một cột mô tả, không tách thành dim riêng ở level 1)
  - measures: `quantity, gross_amount, discount_amount, net_amount`

Ở đây `net_amount` có thể là `quantity * unit_price - discount_amount`. Bạn nên lưu cả các thành phần để sau này thay đổi định nghĩa không phải “đập fact”.

### Lỗi hay gặp
Nhầm fact và dim thường đến từ việc bạn nhìn tên bảng thay vì nhìn mục đích. Một bảng “orders” trong DW không nhất thiết là fact nếu bạn không đo lường gì hoặc grain không rõ.

Trộn nhiều grain trong một bảng là lỗi cực nặng: ví dụ nhét cả “đơn hàng” và “dòng sản phẩm” vào cùng fact, khiến một số dòng đại diện order, một số dòng đại diện item. Khi đó tổng doanh thu sẽ bị nhân hoặc thiếu tùy join.

Measures sai định nghĩa thường xảy ra khi bạn lấy doanh thu từ payments nhưng lại báo cáo theo sales, hoặc tính cả đơn huỷ. Ngay từ đầu phải chốt: “revenue” trong báo cáo này dựa trên sự kiện nào và trạng thái nào.

### Checklist áp dụng
- [ ] Bạn viết được câu grain cho `fact_sales` và kiểm tra tính duy nhất  
- [ ] Bạn phân biệt fact vs dim bằng tiêu chí “đo lường” vs “ngữ cảnh”  
- [ ] Bạn liệt kê được measures và định nghĩa net_amount rõ ràng  
- [ ] Bạn biết vì sao cần surrogate key cho customer/product  

---

## 2) Level 2 — Star Schema, Snowflake và quy trình Kimball (thực dụng)

### Mục tiêu level
Bạn biết thiết kế theo quy trình nghiệp vụ (business process), chọn star/snowflake đúng lúc, và tạo được nhiều fact dùng chung dimension.

### Star vs Snowflake: khi nào chọn cái nào
**Star schema** là fact ở giữa, xung quanh là các dimension “phẳng” (denormalized vừa đủ). Nó dễ hiểu cho analytics, join ít và thường nhanh hơn trong thực tế dự án.

**Snowflake schema** là dimension được chuẩn hoá thành nhiều bảng con (ví dụ product → category → department). Nó hữu ích khi dimension quá lớn, có cấu trúc phân cấp rõ và bạn cần quản lý thay đổi ở cấp cao. Trong đồ án, ưu tiên star để giảm độ phức tạp; snowflake chỉ dùng khi bạn có lý do rõ ràng như “category được quản trị riêng và dùng chung”.

### Quy trình Kimball theo kiểu “làm dự án”
Kimball thực dụng bắt đầu từ **process**. Với e-commerce, process có thể là “Sales”, “Payments”, “Shipments”.

Bạn chọn process xong thì chốt grain cho fact của process đó. Sau đó mới xác định measures (cái gì cần đo) và dimensions (cái gì cần phân tích theo). Thứ tự này tránh việc bạn “vẽ dim trước rồi nhét fact vào”, dễ dẫn đến grain lệch.

### Conformed dimensions và “1 định nghĩa doanh thu”
Conformed dimension là dimension dùng chung giữa nhiều fact với cùng một ý nghĩa, ví dụ `dim_date`, `dim_customer`. Nó giúp bạn join `fact_sales` với `fact_payments` mà không bị “mỗi bảng hiểu khách hàng theo một kiểu”.

Trong thực tế, “revenue” có thể xuất hiện ở sales (đặt hàng) và ở payments (đã thu tiền). Nếu không có conformed dims và quy ước rõ, báo cáo sẽ tranh cãi bất tận vì số khác nhau nhưng ai cũng “đúng” theo cách của mình.

### Ví dụ: thêm fact_payments dùng chung dim_date/dim_customer
Nguồn OLTP:
- `payments(payment_id, order_id, customer_id, paid_ts, amount, method, status, ...)`

Thiết kế DW:
- `fact_payments(grain = 1 row = 1 payment transaction)`
  - keys: `paid_date_key -> dim_date`, `customer_key -> dim_customer`
  - degenerate: `order_id, payment_id`
  - measures: `paid_amount`
  - dim tùy chọn: `dim_payment_method` nếu cần phân tích sâu theo method

Lúc này bạn có thể so sánh “sales net_amount” với “paid_amount” theo ngày và theo nhóm khách. Nếu số lệch, đó là insight: đơn chưa thanh toán, thanh toán trễ, refund…

### Lỗi hay gặp
Chọn snowflake chỉ vì “trông chuẩn hoá cho đẹp” thường làm khó truy vấn và khó dạy BI. Nếu bạn chưa có nhu cầu phân cấp rõ ràng, star thường là lựa chọn tốt.

Một lỗi khác là tạo dimension trùng ý nghĩa nhưng khác khóa và khác logic, khiến join chéo không được. Conformed dims không phải “nice-to-have”, nó là điều kiện để có single truth.

### Checklist áp dụng
- [ ] Bạn chọn được 2 process (Sales + Payments) và chốt grain cho từng fact  
- [ ] Bạn dùng chung `dim_date` và `dim_customer` cho nhiều fact  
- [ ] Bạn giải thích được vì sao star thường ưu tiên trong dự án đầu tay  
- [ ] Bạn mô tả được ít nhất 1 báo cáo cần kết hợp 2 fact (sales vs payments)  

---

## 3) Level 3 — Slowly Changing Dimensions (SCD) và lịch sử dữ liệu

### Mục tiêu level
Bạn biết khi nào cần lưu lịch sử, phân biệt SCD Type 1 và Type 2, và join đúng để báo cáo không “nhảy số”.

### Vì sao DW cần lịch sử
Phân tích thường quan tâm “tại thời điểm đó” chứ không phải hiện tại. Nếu khách chuyển địa chỉ hoặc đổi tier, bạn vẫn muốn biết doanh thu tháng trước đến từ tier nào lúc tháng trước, không bị ghi đè theo tier hiện tại.

Lịch sử còn quan trọng với sản phẩm: giá, nhóm hàng, tình trạng active… Nếu bạn ghi đè giá, bạn sẽ không thể giải thích vì sao revenue thay đổi hoặc margin bị lệch.

### SCD Type 1 vs Type 2 (mục tiêu khác nhau)
**Type 1** là ghi đè: bạn chỉ cần “giá trị mới nhất”, không cần lịch sử. Ví dụ sửa lỗi chính tả tên khách hàng.

**Type 2** là lưu lịch sử: mỗi lần thay đổi quan trọng thì tạo một phiên bản mới của dimension, có `effective_from`, `effective_to`, và cờ `is_current`. Khi join fact với dim, bạn join theo surrogate key tương ứng phiên bản đúng thời điểm.

### Ví dụ: dim_customer đổi tier (Type 2)
Giả sử khách `customer_id=123` từ Silver lên Gold ngày 2025-06-10. Trong DW:
- Bản ghi cũ: `effective_from=...`, `effective_to=2025-06-09`, `is_current=false`
- Bản ghi mới: `effective_from=2025-06-10`, `effective_to=9999-12-31`, `is_current=true`

Khi nạp `fact_sales`, bạn phải lookup `customer_key` theo thời điểm order_ts. Đơn ngày 2025-06-05 phải gắn vào phiên bản Silver, còn đơn ngày 2025-06-12 gắn vào phiên bản Gold.

### Lỗi hay gặp
Lỗi “không có effective_from/to” khiến bạn không thể audit lịch sử và không thể join đúng thời điểm. Lỗi join sai phổ biến là join fact với `dim_customer` theo `customer_id` và `is_current=true`, thế là mọi doanh thu quá khứ bị “đổ” về tier hiện tại.

Một lỗi tinh vi khác là để `effective_to` chồng lấp hoặc bỏ trống khoảng thời gian, làm lookup rơi vào “2 bản ghi” hoặc “không bản ghi nào”. Khi đó số liệu sẽ nhảy hoặc mất.

### Checklist áp dụng
- [ ] Bạn phân loại được thuộc tính nào Type 1, thuộc tính nào Type 2 trong dim_customer  
- [ ] Bạn thiết kế dim Type 2 với `effective_from/effective_to/is_current`  
- [ ] Bạn mô tả được lookup customer_key theo thời điểm giao dịch  
- [ ] Bạn biết lỗi join theo `is_current=true` sẽ làm sai lịch sử như thế nào  

---

## 4) Level 4 — ETL/ELT và pipeline nạp dữ liệu (project-ready)

### Mục tiêu level
Bạn thiết kế được pipeline theo tầng, chạy incremental an toàn, có khả năng resume và backfill mà không nhân đôi dữ liệu.

### ETL vs ELT theo tiêu chí thực tế
ETL nghĩa là transform trước khi load vào kho phân tích; ELT nghĩa là load raw vào trước rồi transform trong kho. Trong dự án hiện đại, ELT thường thực dụng hơn vì bạn giữ được raw để debug và backfill, và scale transform dựa trên engine của kho dữ liệu.

Chọn ETL khi bạn cần transform nặng trước (do giới hạn kho), hoặc dữ liệu nhạy cảm phải mask trước khi vào kho. Chọn ELT khi bạn muốn dễ quan sát, dễ tái chạy, và có lịch sử raw để truy vết.

### Luồng chuẩn: ingest → staging/raw → transform → core/marts → semantic
Tầng **raw/staging** giữ dữ liệu gần như nguyên bản, thêm metadata như `ingested_at`, `source_system`. Tầng **core** tạo fact/dim chuẩn hoá theo mô hình. Tầng **marts/semantic** tổ chức theo nhu cầu báo cáo và metric, ưu tiên trải nghiệm BI.

Điểm quan trọng là “không làm sạch vội ở raw”. Raw là bằng chứng; core mới là nơi bạn chuẩn hoá.

### Incremental load: watermark, upsert/merge, idempotency, backfill
**Watermark** là mốc thời gian hoặc version để biết lần chạy này lấy phần “mới”. Ví dụ dùng `updated_at` của orders.

**Upsert/Merge** là chiến lược ghi: record mới thì insert, record cũ đổi thì update (hoặc đóng/mở version nếu SCD2). Bạn nên thiết kế sao cho chạy lại cùng một khoảng thời gian không tạo bản ghi trùng, đó là **idempotency**.

**Backfill** là nạp lại dữ liệu lịch sử khi có sửa logic hoặc nguồn gửi trễ. Nếu raw giữ đầy đủ và pipeline idempotent, backfill trở thành thao tác “tái chạy có kiểm soát” thay vì “cầu may”.

### Ví dụ: job nạp orders hằng ngày
Giả sử mỗi ngày 2h sáng, bạn ingest `orders` và `order_items` theo `updated_at >= last_watermark`. Dữ liệu vào raw dạng `raw_orders` và `raw_order_items` kèm `ingested_at`.

Ở bước transform core, bạn tạo/ cập nhật `dim_customer` (SCD nếu cần), `dim_product`, và nạp `fact_sales`. Với `fact_sales`, bạn xác định unique key tự nhiên ở grain order_item, ví dụ `(order_id, product_id)` hoặc `order_item_id` nếu có, rồi merge theo key đó để tránh trùng.

Nếu có record cập nhật (đổi quantity, đổi discount), merge sẽ update measures tương ứng hoặc tạo điều chỉnh theo quy ước của bạn. Điều quan trọng là bạn phải ghi rõ trong tài liệu: “fact_sales phản ánh trạng thái cuối của order_item” hay “fact_sales là ledger có dòng điều chỉnh”.

### Lỗi hay gặp
Lỗi hay gặp nhất là incremental dựa vào `created_at` thay vì `updated_at`, khiến record cập nhật không bao giờ được lấy. Một lỗi khác là merge không có khóa duy nhất rõ ràng, làm mỗi lần chạy lại thì dữ liệu phình lên.

Nhiều bạn “fix nhanh” bằng cách truncate và reload full mỗi lần. Cách này dùng được cho toy data, nhưng vào dự án thật sẽ chết vì thời gian chạy và chi phí.

### Checklist áp dụng
- [ ] Bạn mô tả được pipeline theo 4–5 tầng và trách nhiệm mỗi tầng  
- [ ] Bạn chọn được watermark hợp lý và giải thích vì sao  
- [ ] Bạn thiết kế được merge/upsert idempotent cho fact_sales  
- [ ] Bạn có kế hoạch backfill khi logic thay đổi hoặc nguồn gửi trễ  

---

## 5) Level 5 — Data Quality, Testing và Observability

### Mục tiêu level
Bạn có bộ kiểm tra tối thiểu để “đỡ chết vì số liệu sai”, và có cách phát hiện pipeline trễ trước khi người dùng báo.

### Data quality không phải nice-to-have
Sai số liệu phá niềm tin nhanh hơn dashboard xấu. Một khi người dùng thấy “doanh thu hôm qua khác nhau ở 2 nơi”, họ sẽ quay về Excel và DW coi như thất bại.

Chất lượng dữ liệu trong DW còn là chất lượng quy trình: bạn muốn phát hiện lỗi sớm, định vị lỗi nhanh, và khôi phục có kịch bản.

### Kiểm tra tối thiểu (thực dụng)
Row count giúp bắt lỗi rớt dữ liệu do ingest fail hoặc filter sai. Null check và uniqueness giúp phát hiện key bị thiếu hoặc duplicate. Referential integrity giúp đảm bảo fact không mồ côi dimension. Freshness giúp phát hiện pipeline bị trễ dù dữ liệu “trông vẫn đúng”.

Bạn không cần một hệ thống testing phức tạp để bắt đầu. Bạn cần một bộ test nhỏ nhưng chạy đều và có cảnh báo.

### Data contracts ở mức đủ dùng
Data contract tối thiểu là cam kết schema và expectation: cột nào bắt buộc, kiểu dữ liệu, định nghĩa key, và SLA freshness. Khi nguồn đổi schema mà không báo, contract sẽ fail sớm thay vì làm sai số âm thầm.

Trong đồ án, bạn có thể viết contract dưới dạng file YAML/Markdown mô tả bảng raw và bảng core, kèm các rule kiểm tra. Quan trọng là có “owner” và “hành động khi fail”, không chỉ là tài liệu treo.

### Ví dụ: bộ test cho fact_sales và dim_customer
Với `fact_sales`, bạn kiểm tra `date_key/product_key/customer_key` không null và referential integrity join được sang dims. Bạn kiểm tra uniqueness theo grain key (ví dụ `order_item_id` hoặc `(order_id, product_key)`).

Với `dim_customer` Type 2, bạn kiểm tra không có khoảng thời gian chồng lấp cho cùng `customer_id`. Bạn cũng kiểm tra mỗi `customer_id` có đúng một bản ghi `is_current=true`.

Freshness: nếu `fact_sales` chưa có dữ liệu cho ngày hôm qua (theo timezone quy ước), bạn cảnh báo “pipeline trễ”, trước khi team BI mở dashboard.

### Lỗi hay gặp
Chỉ test “schema đúng” nhưng không test “logic đúng” khiến metric vẫn sai. Ngược lại, test quá phức tạp từ đầu làm bạn không chạy được đều.

Một lỗi phổ biến khác là không có nơi tập trung logs/metrics, đến lúc sai số không biết pipeline fail ở ingest hay ở transform.

### Checklist áp dụng
- [ ] Bạn có ít nhất 5 test: row count, null, unique, RI, freshness  
- [ ] Bạn định nghĩa được grain key để test uniqueness của fact_sales  
- [ ] Bạn có rule kiểm tra SCD2: is_current duy nhất + không overlap  
- [ ] Bạn có cơ chế cảnh báo khi freshness fail (dù chỉ là log + email giả lập)  

---

## 6) Level 6 — Hiệu năng truy vấn và tối ưu chi phí

### Mục tiêu level
Bạn hiểu vì sao truy vấn DW chậm và biết 3–4 đòn tối ưu “đúng bệnh” mà không phụ thuộc vendor.

### Vì sao DW hay chậm
Chậm thường đến từ scan quá lớn và join sai. Khi bạn join fact rất lớn với dim mà filter không hiệu quả, engine phải đọc nhiều dữ liệu và shuffle nhiều.

Một nguyên nhân khác là bạn phân tích ở grain quá chi tiết trong khi báo cáo chỉ cần tổng hợp theo ngày/tuần. Làm đúng nghĩa là chuẩn bị “đường đi” cho query phổ biến, thay vì bắt mọi query đi qua đường rừng.

### Khái niệm tối ưu ở mức DW (trung lập vendor)
**Partitioning theo thời gian** giúp query theo khoảng ngày/tháng đọc ít dữ liệu hơn. **Clustering/sort key** giúp các filter/join phổ biến tận dụng locality dữ liệu. **Pre-aggregation** và **materialized view** giúp báo cáo phổ biến chạy nhanh vì đã tính sẵn ở grain phù hợp.

Điểm tinh tế là: tối ưu không nên phá định nghĩa metric. Bạn tối ưu cách lưu và cách tính, không đổi “ý nghĩa” của revenue.

### Ví dụ: báo cáo doanh thu theo ngày bị chậm
Dashboard chạy câu “revenue theo ngày 90 ngày gần nhất” mà fact_sales quá lớn. Bạn tạo bảng aggregate `agg_daily_sales(date_key, product_category, revenue, order_count)` hoặc materialized view ở grain ngày và nhóm hàng.

Khi đó dashboard query vào aggregate thay vì fact chi tiết. Còn khi cần drill-down, bạn vẫn giữ fact_sales để truy được chi tiết.

### Lỗi hay gặp
Index hóa mọi thứ theo tư duy OLTP thường không giúp nhiều trong DW columnar, và còn tăng chi phí ghi. Một lỗi khác là tạo aggregate sai grain, rồi dashboard dùng aggregate cho câu hỏi mà aggregate không đủ chi tiết, dẫn đến số sai hoặc double-count.

Nhiều team tối ưu trước khi có workload thật, cuối cùng tốn công mà không nhanh hơn. Cách thực dụng là tối ưu theo top queries và theo pattern truy cập.

### Checklist áp dụng
- [ ] Bạn xác định được 3 query phổ biến và tối ưu theo chúng  
- [ ] Bạn partition theo thời gian cho fact lớn và giải thích lợi ích  
- [ ] Bạn tạo được 1 aggregate table/materialized view mà không đổi định nghĩa metric  
- [ ] Bạn biết dấu hiệu join sai grain gây double-count và cách phát hiện  

---

## 7) Level 7 — Semantic Layer, Metrics và “Single Definition of Truth”

### Mục tiêu level
Bạn biết chuẩn hoá metric để không còn “mỗi team một kiểu”, và mô tả metric đủ rõ để người khác dùng đúng.

### Vấn đề “mỗi team định nghĩa doanh thu một kiểu”
Sales team thích doanh thu theo đơn đặt (kể cả chưa thu tiền), Finance thích doanh thu theo tiền đã thu (net of refund), Growth team tính theo user cohorts. Nếu không có semantic/metrics layer, mọi người sẽ viết SQL riêng và dashboard sẽ mâu thuẫn.

Semantic layer không nhất thiết là một sản phẩm vendor. Nó là một lớp quy ước: metric được định nghĩa, đặt tên, versioned, và dùng lại. Bạn có thể bắt đầu bằng một schema `semantic` chứa view chuẩn và một file “metric registry”.

### Chuẩn hoá metric: cần những gì để dùng đúng
Một metric chuẩn phải có: tên rõ, công thức, grain, filter, nguồn dữ liệu, và owner chịu trách nhiệm. Grain và filter là chỗ hay bị “ngầm”: ví dụ revenue chỉ tính orders status=COMPLETED, loại CANCELLED/REFUNDED, và tính theo order_date hay paid_date.

Khi metric có đủ metadata, người đọc dashboard hiểu “con số này là cái gì”, và bạn debug được khi số lệch.

### Ví dụ metric trong e-commerce
`revenue_net` có thể định nghĩa là tổng `net_amount` từ `fact_sales` cho các order_items thuộc orders ở trạng thái completed, theo `order_date`. `order_count` là số order_id distinct ở trạng thái completed theo `order_date`.

`active_users` tuỳ domain định nghĩa, nhưng nếu bạn dùng cho e-commerce, hãy chốt là “số customer distinct có ít nhất 1 order completed trong ngày” hoặc “có activity event” nếu bạn có event tracking. Quan trọng là không để mỗi người tự hiểu.

### Lỗi hay gặp
Metric trùng tên khác nghĩa là thảm hoạ, vì dashboard nhìn “revenue” tưởng cùng một thứ. Filter ngầm cũng nguy hiểm: một view đã lọc status nhưng người dùng lại lọc thêm, dẫn đến loại trừ quá mức.

Join ẩn trong semantic view nếu không ghi rõ grain cũng dễ tạo double-count. Một view “doanh thu theo khách” mà join thêm dim_product có thể làm số nhân lên nếu không group đúng.

### Checklist áp dụng
- [ ] Bạn có “metric registry” mô tả ít nhất 5 metric: tên, công thức, grain, filter, nguồn, owner  
- [ ] Bạn tạo semantic views dùng lại thay vì copy SQL rải rác  
- [ ] Bạn phân biệt rõ revenue theo order_date vs paid_date và ghi vào định nghĩa  
- [ ] Bạn có quy ước đặt tên nhất quán (revenue_net, order_count, ...)  

---

## 8) Level 8 — Governance, Security và vận hành production

### Mục tiêu level
Bạn biết cách “đưa DW vào đời sống”: phân quyền, bảo vệ PII, truy vết lineage, và xử lý incident dữ liệu.

### RBAC/ABAC gắn với thực tế và PII masking
RBAC là phân quyền theo vai trò: analyst xem được mart, engineer xem được raw. ABAC là theo thuộc tính: chỉ team Finance xem được cột cost, hoặc chỉ region manager xem dữ liệu region của họ.

PII như email, số điện thoại, địa chỉ cần có chiến lược: mask, tokenize hoặc tách riêng “PII vault” tuỳ mức độ dự án. Dù làm đồ án, bạn vẫn nên thể hiện tư duy: không phải ai cũng được xem mọi thứ.

### Audit, lineage, retention, backup/DR ở mức dự án
Audit giúp trả lời “ai chạy job, ai sửa metric, ai xem dữ liệu nhạy cảm”. Lineage giúp biết dashboard này phụ thuộc bảng nào, để khi bảng lỗi bạn khoanh vùng nhanh.

Retention là chính sách giữ dữ liệu: raw giữ 90 ngày hay 1 năm? core giữ bao lâu? Backup/DR là kế hoạch khôi phục khi hỏng: tối thiểu là có snapshot định kỳ và script tái tạo bảng từ raw.

### Quy trình xử lý data incident
Khi phát hiện dashboard sai, bước đầu là **khoanh vùng**: sai ở metric hay sai ở dữ liệu? sai từ ngày nào? sai tất cả hay chỉ một phân khúc?

Sau đó bạn **đi ngược lineage**: semantic → mart → core → raw → source để xác định tầng nào bắt đầu lệch. Fix xong phải có **postmortem**: nguyên nhân gốc, vì sao test không bắt được, và thêm guardrail để không tái diễn.

### Lỗi hay gặp
Nhiều dự án bỏ qua ownership nên khi sai số, không ai chịu trách nhiệm. Một lỗi khác là cho analyst quyền đọc raw chứa PII, rồi “dữ liệu rò rỉ vì thuận tiện”.

### Checklist áp dụng
- [ ] Bạn phân loại dữ liệu nhạy cảm và có chiến lược masking tối thiểu  
- [ ] Bạn mô tả được lineage từ dashboard về bảng core/raw  
- [ ] Bạn có policy retention (dù giả lập) và kế hoạch backup cơ bản  
- [ ] Bạn viết được playbook xử lý incident: detect → triage → fix → postmortem  

---

## 9) Level 9 — Nâng cao: pattern và kiến trúc hiện đại

### Mục tiêu level
Bạn biết các hướng hiện đại để “đọc hiểu và cân nhắc”, không bị cuốn vào độ phức tạp khi làm dự án sinh viên.

### Data Vault: khi nào cân nhắc
Data Vault phù hợp khi nguồn nhiều, thay đổi schema liên tục, cần audit mạnh và muốn tách “hubs/links/satellites” để linh hoạt. Đổi lại, nó phức tạp hơn cho người mới, và thường cần thêm lớp mart kiểu Kimball để BI dùng dễ.

Trong đồ án e-commerce đơn giản, Kimball/star schema thường đủ. Bạn chỉ nên nhắc Data Vault như một lựa chọn khi bài toán “nhiều nguồn, nhiều thay đổi, cần audit cao”.

### Near real-time, streaming và CDC
Near real-time hữu ích khi cần dashboard cập nhật phút/giờ, hoặc cần theo dõi gian lận. CDC (Change Data Capture) giúp lấy thay đổi từ OLTP thay vì full extract, giảm tải và giảm latency.

Trade-off là độ phức tạp vận hành tăng: late events, ordering, replay, exactly-once. Với đồ án, bạn có thể mô phỏng CDC bằng trường `updated_at` và batch chạy thường xuyên hơn, rồi ghi rõ hạn chế.

### Tư duy quan trọng: bắt đầu đơn giản, mở rộng có chủ đích
Một DW tốt thường bắt đầu từ 1–2 process, vài dims conformed, và bộ metric cốt lõi. Khi đã ổn định, bạn mới mở rộng process, thêm lịch sử sâu hơn, và tối ưu theo workload.

Nếu bạn làm ngay streaming + vault + semantic phức tạp từ đầu, bạn sẽ “xây toà lâu đài” nhưng không có dashboard nào đáng tin để demo.

### Checklist áp dụng
- [ ] Bạn nêu được khi nào Data Vault đáng cân nhắc và vì sao nó phức tạp  
- [ ] Bạn giải thích được CDC/streaming giúp gì và đánh đổi gì  
- [ ] Bạn chọn phạm vi phù hợp cho đồ án: ưu tiên batch + star + metrics rõ  
- [ ] Bạn có kế hoạch mở rộng sau MVP (thêm fact, thêm mart, giảm latency)  

---

## 10) Capstone Project — Dự án DW end-to-end (bắt buộc)

### Mục tiêu
Bạn có một dự án mẫu hoàn chỉnh: từ nguồn OLTP giả lập → DW (fact/dim) → pipeline incremental → data quality → truy vấn báo cáo → checklist DoD.

### 10.1 Mô tả dữ liệu nguồn (OLTP giả lập)
Bộ bảng tối thiểu:
- `orders(order_id, customer_id, order_ts, status, updated_at)`
- `order_items(order_item_id, order_id, product_id, quantity, unit_price, discount_amount, updated_at)`
- `payments(payment_id, order_id, customer_id, paid_ts, paid_amount, status, updated_at)`
- `products(product_id, sku, name, category, updated_at)`
- `customers(customer_id, email, name, address, tier, updated_at)`

Bạn có thể tạo dữ liệu bằng script hoặc file CSV. Điều quan trọng là có `updated_at` để làm incremental và có thay đổi để test SCD (ví dụ tier đổi).

### 10.2 Mô hình DW cuối cùng (fact/dim, grain, measures)
Dimensions:
- `dim_date(date_key, date, day, month, year, week, ...)`
- `dim_product(product_key, product_id, sku, name, category, ...)` (Type 1 hoặc Type 2 tuỳ bạn muốn lưu lịch sử category)
- `dim_customer(customer_key, customer_id, email_masked, name, address, tier, effective_from, effective_to, is_current)` (Type 2)

Facts:
- `fact_sales(grain = 1 row = 1 order_item)`
  - keys: `order_date_key, product_key, customer_key`
  - degenerate: `order_id, order_item_id`
  - measures: `quantity, gross_amount, discount_amount, net_amount`
- `fact_payments(grain = 1 row = 1 payment)`
  - keys: `paid_date_key, customer_key`
  - degenerate: `payment_id, order_id`
  - measures: `paid_amount`

Bạn cần ghi rõ định nghĩa: `net_amount = quantity * unit_price - discount_amount`. Nếu status ảnh hưởng metric, bạn đưa nó vào semantic layer thay vì nhét vào fact, để dễ thay đổi.

### 10.3 Kế hoạch pipeline (lịch chạy, incremental, backfill)
Lịch chạy đề xuất:
- Ingest raw: mỗi ngày 02:00 (hoặc mỗi giờ nếu muốn demo freshness)
- Transform core: ngay sau ingest
- Build marts/semantic: sau core, vì nó phụ thuộc core

Incremental:
- Watermark theo `updated_at` cho từng bảng nguồn
- Raw append-only kèm `ingested_at`
- Core merge/upsert theo natural key rõ ràng:
  - dim_product: key = product_id
  - dim_customer SCD2: key = customer_id + effective range
  - fact_sales: key = order_item_id
  - fact_payments: key = payment_id

Backfill:
- Khi đổi logic metric hoặc phát hiện nguồn gửi trễ, bạn re-run theo date range, đảm bảo idempotent. Raw giữ đủ để tái dựng core mà không phải gọi lại OLTP.

### 10.4 Bộ kiểm tra chất lượng dữ liệu tối thiểu
Bạn áp dụng các test:
- Row count: so sánh raw_orders hôm nay với hôm qua, cảnh báo nếu tụt bất thường
- Null check: các key trong fact không null
- Uniqueness: `order_item_id` unique trong fact_sales, `payment_id` unique trong fact_payments
- Referential integrity: mọi `product_key/customer_key/date_key` trong fact join được sang dim
- SCD2 checks: mỗi customer_id chỉ có 1 is_current, và không overlap effective ranges
- Freshness: fact_sales có dữ liệu đến ngày D-1 (theo timezone dự án)

### 10.5 8–12 truy vấn phân tích mẫu (SQL minh họa)
Dưới đây là các query mẫu theo hướng “làm báo cáo”. Bạn có thể điều chỉnh tên cột theo schema của bạn.

1) Doanh thu net theo ngày (90 ngày gần nhất)
```sql
SELECT d.date,
       SUM(s.net_amount) AS revenue_net
FROM fact_sales s
JOIN dim_date d ON s.order_date_key = d.date_key
GROUP BY d.date
ORDER BY d.date;
````

2. Top 10 sản phẩm theo doanh thu trong tháng hiện tại

```sql
SELECT p.name,
       SUM(s.net_amount) AS revenue_net
FROM fact_sales s
JOIN dim_date d ON s.order_date_key = d.date_key
JOIN dim_product p ON s.product_key = p.product_key
WHERE d.year = 2026 AND d.month = 2
GROUP BY p.name
ORDER BY revenue_net DESC
FETCH FIRST 10 ROWS ONLY;
```

3. Doanh thu theo category theo tuần

```sql
SELECT d.year, d.week, p.category,
       SUM(s.net_amount) AS revenue_net
FROM fact_sales s
JOIN dim_date d ON s.order_date_key = d.date_key
JOIN dim_product p ON s.product_key = p.product_key
GROUP BY d.year, d.week, p.category
ORDER BY d.year, d.week, revenue_net DESC;
```

4. Order count theo ngày (distinct order_id)

```sql
SELECT d.date,
       COUNT(DISTINCT s.order_id) AS order_count
FROM fact_sales s
JOIN dim_date d ON s.order_date_key = d.date_key
GROUP BY d.date
ORDER BY d.date;
```

5. AOV theo ngày (Average Order Value)

```sql
SELECT d.date,
       SUM(s.net_amount) / NULLIF(COUNT(DISTINCT s.order_id), 0) AS aov
FROM fact_sales s
JOIN dim_date d ON s.order_date_key = d.date_key
GROUP BY d.date
ORDER BY d.date;
```

6. Doanh thu theo tier khách hàng (theo lịch sử SCD2 đã gắn key đúng thời điểm)

```sql
SELECT c.tier,
       SUM(s.net_amount) AS revenue_net
FROM fact_sales s
JOIN dim_customer c ON s.customer_key = c.customer_key
GROUP BY c.tier
ORDER BY revenue_net DESC;
```

7. Sales vs Payments theo ngày (chênh lệch dòng tiền)

```sql
SELECT d.date,
       SUM(s.net_amount) AS sales_net,
       SUM(p.paid_amount) AS paid_amount,
       SUM(s.net_amount) - SUM(p.paid_amount) AS gap
FROM dim_date d
LEFT JOIN fact_sales s ON s.order_date_key = d.date_key
LEFT JOIN fact_payments p ON p.paid_date_key = d.date_key
GROUP BY d.date
ORDER BY d.date;
```

8. Tỷ lệ thanh toán trễ: đơn có sales nhưng chưa có payment trong 7 ngày

```sql
SELECT d.date,
       COUNT(DISTINCT s.order_id) AS orders_sold,
       COUNT(DISTINCT CASE WHEN pay.order_id IS NOT NULL THEN s.order_id END) AS orders_paid,
       1.0 * (COUNT(DISTINCT s.order_id) - COUNT(DISTINCT CASE WHEN pay.order_id IS NOT NULL THEN s.order_id END))
           / NULLIF(COUNT(DISTINCT s.order_id), 0) AS late_ratio
FROM fact_sales s
JOIN dim_date d ON s.order_date_key = d.date_key
LEFT JOIN (
  SELECT DISTINCT order_id
  FROM fact_payments
) pay ON pay.order_id = s.order_id
GROUP BY d.date
ORDER BY d.date;
```

9. Repeat customers theo tháng (khách có >= 2 đơn trong tháng)

```sql
SELECT d.year, d.month,
       COUNT(DISTINCT CASE WHEN t.order_cnt >= 2 THEN t.customer_key END) AS repeat_customers
FROM (
  SELECT s.customer_key, d.year, d.month, COUNT(DISTINCT s.order_id) AS order_cnt
  FROM fact_sales s
  JOIN dim_date d ON s.order_date_key = d.date_key
  GROUP BY s.customer_key, d.year, d.month
) t
JOIN dim_date d ON d.year = t.year AND d.month = t.month
GROUP BY d.year, d.month
ORDER BY d.year, d.month;
```

10. Cohort đơn giản: tháng mua đầu tiên và doanh thu các tháng sau

```sql
WITH first_month AS (
  SELECT customer_key, MIN(d.year * 100 + d.month) AS cohort_yyyymm
  FROM fact_sales s
  JOIN dim_date d ON s.order_date_key = d.date_key
  GROUP BY customer_key
),
sales_month AS (
  SELECT s.customer_key, (d.year * 100 + d.month) AS yyyymm, SUM(s.net_amount) AS revenue
  FROM fact_sales s
  JOIN dim_date d ON s.order_date_key = d.date_key
  GROUP BY s.customer_key, (d.year * 100 + d.month)
)
SELECT f.cohort_yyyymm,
       sm.yyyymm,
       SUM(sm.revenue) AS revenue
FROM first_month f
JOIN sales_month sm ON sm.customer_key = f.customer_key
GROUP BY f.cohort_yyyymm, sm.yyyymm
ORDER BY f.cohort_yyyymm, sm.yyyymm;
```

11. Data quality query: tìm fact mồ côi dimension (should be 0)

```sql
SELECT COUNT(*) AS orphan_rows
FROM fact_sales s
LEFT JOIN dim_product p ON s.product_key = p.product_key
WHERE p.product_key IS NULL;
```

12. Freshness query: ngày mới nhất trong fact_sales

```sql
SELECT MAX(d.date) AS latest_sales_date
FROM fact_sales s
JOIN dim_date d ON s.order_date_key = d.date_key;
```

### 10.6 Definition of Done (DoD) — Checklist ngắn

* [ ] Có mô hình DW với ít nhất 2 fact (sales, payments) và 3 dim conformed (date, customer, product)
* [ ] Fact có grain viết thành câu rõ ràng, có khóa duy nhất, không trộn grain
* [ ] Pipeline có raw → core → semantic, chạy incremental theo watermark và idempotent khi rerun
* [ ] Dim_customer có SCD2 và fact gắn đúng customer_key theo thời điểm giao dịch
* [ ] Có tối thiểu 5 test data quality + 1 kiểm tra freshness/độ trễ pipeline
* [ ] Có tối thiểu 8 query báo cáo mẫu chạy được và giải thích metric rõ ràng
* [ ] Có “metric registry” mô tả revenue/order_count/AOV và các filter/grain
* [ ] Có mô tả phân quyền/PII masking tối thiểu và playbook xử lý incident

---

## 5–8 ý quan trọng để nhớ (tóm tắt)

* Grain quyết định tất cả: sai grain là sai hệ thống, không phải sai query.
* Conformed dimensions là điều kiện để có “single definition of truth”.
* Raw là bằng chứng để debug và backfill; core là nơi chuẩn hoá; semantic là nơi chuẩn hoá metric.
* SCD2 không khó, khó là join/lookup đúng thời điểm và kiểm tra overlap.
* Incremental + idempotency giúp bạn dám rerun, dám backfill mà không sợ phình dữ liệu.
* Performance tốt đến từ đúng grain + đúng đường query phổ biến, không phải “tối ưu mọi thứ”.
* Metric phải có tên, công thức, grain, filter, nguồn, owner; thiếu một thứ là dễ hiểu sai.
* Governance là để vận hành: quyền truy cập, audit, lineage, incident handling.

---

## Danh sách lỗi thường gặp (để tự bắt mình)

* Trộn nhiều grain trong 1 fact hoặc không viết được câu grain.
* Join dim theo natural key và `is_current=true`, làm mất lịch sử.
* Incremental dựa `created_at` nên bỏ sót update.
* Merge không có unique key rõ ràng nên chạy lại bị duplicate.
* Metric “revenue” không ghi filter/status nên mỗi người hiểu một kiểu.
* Tạo aggregate sai grain khiến dashboard nhanh nhưng số sai.

```
 