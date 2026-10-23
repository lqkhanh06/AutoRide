# Phân Tích Tính Toàn Vẹn: Vai Trò Bắt Buộc Của Cột `damage_fee`

**Hệ thống:** Quản lý thuê xe tự lái AutoRide  
**Tác giả:** Data Architect  

---

Trong quy trình thực tế (UML Activity Diagram), việc trả xe tồn tại nhánh rẽ phát sinh sự cố hư hỏng phương tiện. Nếu không có cột `damage_fee` trong bảng `Rentals`, hệ thống sẽ gãy đứt tính toàn vẹn ở 3 khía cạnh:

1. **Khép kín dòng tiền:** Công thức hoàn cọc bắt buộc: `Tiền hoàn lại = Tiền cọc - Phí trễ hạn - Phí sửa chữa`. Thiếu `damage_fee`, hệ thống không có dữ liệu đầu vào để tự động tính toán, buộc nhân viên hoàn toàn bộ tiền cọc hoặc thu tiền mặt thủ công ngoài hệ thống, gây thất thoát lợi nhuận nghiêm trọng.
2. **Minh bạch và đối soát kế toán:** Cột `damage_fee` là căn cứ ghi nhận khoản thu bù đắp chi phí bảo dưỡng xe, giúp cân bằng giữa chi phí xưởng sửa chữa và doanh thu thu từ khách hàng.
3. **Lưu vết pháp lý và lịch sử hợp đồng:** Giá trị thiệt hại gắn liền với hợp đồng thuê cụ thể, giúp đối chiếu trực tiếp với biên bản kiểm tra trong bảng `Inspections` khi có khiếu nại.
