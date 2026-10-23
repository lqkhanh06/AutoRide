# Nhật Ký Tương Tác Kỹ Thuật Với AI (AI Prompt Log)

**Dự án:** Tái cấu trúc cơ sở dữ liệu AutoRide  
**Vai trò:** Data Architect  

---

### Giai đoạn 1: Lựa chọn kiểu dữ liệu tài chính chống thất thoát doanh thu
* **Prompt học viên gửi:**  
  > "Khi lưu trữ các trường tài chính như `security_deposit`, `late_fee`, `damage_fee` trong MySQL, tại sao tuyệt đối không được dùng `FLOAT` hay `DOUBLE`? Kiểu dữ liệu `DECIMAL(12, 2)` có ưu thế gì trong bài toán đối soát hoàn cọc?"
* **Kết luận & Áp dụng:**  
  - `FLOAT`/`DOUBLE` là kiểu dữ liệu xấp xỉ nhị phân, dễ gây ra sai số làm tròn số học (Precision Loss) sau nhiều phép cộng/trừ tiền, khiến sổ sách kế toán bị lệch.
  - Áp dụng `DECIMAL(12, 2)` (Fixed-point) kết hợp `DEFAULT 0.00` và ràng buộc `CHECK (>= 0)` đảm bảo số tiền luôn chính xác tuyệt đối và không bị âm.

---

### Giai đoạn 2: Phân tích kiến trúc bảng Biên bản kiểm tra xe (Inspections)
* **Prompt học viên gửi:**  
  > "Tại sao nên tách `Inspections` ra bảng riêng thay vì thêm cột `damage_description` vào bảng `Rentals`? Nên thiết kế mối quan hệ này là 1-1 hay 1-N?"
* **Kết luận & Áp dụng:**  
  - Tách bảng tuân thủ dạng chuẩn chuẩn hóa CSDL (3NF). Một xe khi giao và nhận có thể có nhiều lần kiểm tra (lúc giao xe nhận biên bản bàn giao, lúc trả xe lập biên bản thu hồi), hoặc nhiều hạng mục lỗi khác nhau. Nếu nhồi nhét vào `Rentals`, bảng sẽ chứa nhiều giá trị `NULL` cho các chuyến đi an toàn không phát sinh hư hỏng, lãng phí bộ nhớ và khó mở rộng.
  - Thiết kế quan hệ 1-N giữa `Rentals` và `Inspections`, khóa ngoại liên kết kèm `ON DELETE RESTRICT` để chống việc xóa hợp đồng làm mất lịch sử biên bản kiểm tra.

---

### Giai đoạn 3: Xử lý giá trị NULL trong biểu thức tính toán hoàn cọc
* **Prompt học viên gửi:**  
  > "Trong MySQL, nếu một trong các cột `late_fee` hoặc `damage_fee` có giá trị `NULL`, phép tính `(security_deposit - late_fee - damage_fee)` sẽ trả về kết quả gì và cách phòng tránh ra sao?"
* **Kết luận & Áp dụng:**  
  - Trong phép toán số học SQL, bất kỳ giá trị nào trừ đi `NULL` đều cho ra kết quả `NULL`, dẫn đến việc không thể hiển thị số tiền hoàn trả cho khách.
  - Giải pháp triệt để: Đặt `NOT NULL DEFAULT 0.00` ở tầng DDL, hoặc dùng hàm `COALESCE(late_fee, 0)` trong các câu lệnh SELECT để đảm bảo tính an toàn dữ liệu.
