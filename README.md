# AutoRide Database Re-architecture (Cơ Sở Dữ Liệu Thuê Xe Tự Lái AutoRide)

Dự án tái cấu trúc cơ sở dữ liệu cho startup thuê xe tự lái AutoRide, khắc phục hoàn toàn sự cố thất thoát lợi nhuận và lệch pha giữa UML Activity Diagram và thiết kế CSDL MySQL.

## Danh mục tài liệu trong Repository:
1. [`autoride_db.sql`](autoride_db.sql): File kịch bản DDL (tạo bảng, Trigger kiểm soát nghiệp vụ), DML mô phỏng kịch bản khách trả xe bị hư hỏng, và câu lệnh SELECT tính toán chính xác số tiền hoàn cọc.
2. [`er_activity_mapping.md`](er_activity_mapping.md): Đoạn phân tích ngắn (dưới 200 từ) giải thích lý do tại sao cột `damage_fee` là bắt buộc đối với tính toàn vẹn hệ thống.
3. [`ai_prompt_log.md`](ai_prompt_log.md): Nhật ký trao đổi kỹ thuật với AI về kiểu dữ liệu tài chính `DECIMAL`, chuẩn hóa bảng `Inspections`, và xử lý phép tính an toàn với giá trị `NULL`.

## Hướng dẫn chạy thử nghiệm:
1. Mở MySQL Workbench hoặc MySQL CLI.
2. Chạy toàn bộ file `autoride_db.sql` để khởi tạo Database, Tables, Trigger và nạp dữ liệu kịch bản mẫu.
