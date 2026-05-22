# Plan triển khai project mô phỏng VGA Controller (team 4 người)

## 1) Bài toán và phạm vi
- Mục tiêu: xây dựng project **mô phỏng VGA Controller bằng Verilog/SystemVerilog** để hiển thị lại ảnh nguồn có sẵn (JPG -> HEX -> frame output).
- Phạm vi đã chốt: **chỉ mô phỏng**, không triển khai FPGA board.
- Repo hiện tại chỉ dùng làm **tham khảo kiến trúc và luồng xử lý**, không bê nguyên trạng.

## 2) Phân tích hiện trạng code tham khảo
- Đã có pipeline cơ bản: `vga_timing.sv` -> `mem_interface.sv` -> `top_module.sv` + testbench + script Python chuyển đổi ảnh.
- Luồng dữ liệu ảnh đã có: `jpgtohex.py` (JPG -> HEX) và `txttopng.py` (TXT -> JPG).
- Có tài liệu phân công cũ (`PHAN_CONG_NHIEM_VU.md`) và kết quả mô phỏng trong `Results\`.
- Các điểm cần xử lý nếu dùng làm nền tham khảo:
  - Không nhất quán tín hiệu reset (`reset` vs `reset_n`) giữa module/top/testbench.
  - Không nhất quán độ rộng `pixel_x/pixel_y` giữa các file.
  - Cần chuẩn hóa độ trễ pipeline `active_video` và RGB để tránh lệch ảnh.

## 3) Hướng triển khai đề xuất
1. Chuẩn hóa spec mô phỏng:
   - Chọn timing XGA 1024x768 @ 60Hz.
   - Chốt interface thống nhất cho mọi module (`clk`, `reset_n`, `pixel_x/y`, `active_video`, `RGB`, `hsync/vsync`).
2. Dựng lại module theo hướng sạch:
   - `vga_timing`: counter/FSM timing chuẩn, active-low sync chuẩn.
   - `mem_interface`: đọc `SourceImage.hex`, ánh xạ địa chỉ `addr = y*WIDTH + x`.
   - `top_module`: tích hợp timing + memory + pipeline alignment.
3. Dựng bộ verify:
   - `tb_vga_timing`: verify line/frame length, active region.
   - `tb_top_module`: capture đủ 1024x768 pixel ra `ReconstructedImage.txt`.
4. Chốt pipeline ảnh:
   - Python script chuẩn hóa input/output, đảm bảo định dạng RGB24 đồng nhất.
   - So sánh ảnh nguồn và ảnh tái tạo ở mức trực quan + checksum cơ bản.
5. Đóng gói bàn giao:
   - Cấu trúc thư mục rõ ràng (`Code`, `Python`, `Results`, `Docs`).
   - Hướng dẫn chạy lại full flow từ ảnh nguồn tới ảnh tái tạo.

## 4) Phân công cho nhóm 4 người

### Thành viên 1 - Timing Core Owner
- Phụ trách: `vga_timing.sv`, `tb_vga_timing.sv`.
- Deliverable:
  - Timing XGA đúng thông số (H/V active, front porch, sync, back porch).
  - `hsync/vsync` active-low đúng pha.
  - Testbench timing pass với các check chính.

### Thành viên 2 - Memory & Image Data Owner
- Phụ trách: `mem_interface.sv`, `jpgtohex.py`, dữ liệu `SourceImage.hex`.
- Deliverable:
  - Bộ chuyển đổi ảnh JPG -> HEX đúng RGB24.
  - Địa chỉ hóa pixel đúng toàn frame.
  - Bộ ảnh test chuẩn (ít nhất: ảnh thật, ảnh gradient, ảnh color-bar).

### Thành viên 3 - Integration Owner
- Phụ trách: `top_module.sv`.
- Deliverable:
  - Tích hợp ổn định timing + memory + output gating.
  - Đồng bộ độ trễ dữ liệu để không lệch vùng hiển thị.
  - Interface module thống nhất, dễ mở rộng.

### Thành viên 4 - Verification & Report Owner
- Phụ trách: `tb_top_module.sv`, `txttopng.py`, thư mục `Results\`.
- Deliverable:
  - Capture full frame ra `ReconstructedImage.txt`.
  - Dựng ảnh tái tạo và đối chiếu với ảnh nguồn.
  - Tổng hợp báo cáo kết quả mô phỏng + issue log + cách fix.

## 5) Quy trình phối hợp
1. Thành viên 1 và 2 làm song song, chốt spec interface chung ngay từ đầu.
2. Thành viên 3 tích hợp ngay khi có bản stable từ 1 và 2.
3. Thành viên 4 chạy regression và trả bug đúng owner.
4. Chỉ chốt khi đạt đủ tiêu chí done.

## 6) Tiêu chí hoàn thành (Definition of Done)
- Mô phỏng chạy ổn định và capture đủ 1024x768 pixel/frame.
- Sync/timing đúng chuẩn XGA trong testbench.
- Ảnh tái tạo khớp ảnh nguồn ở mức trực quan (không lệch dòng/cột/màu rõ rệt).
- Full flow tái chạy được từ ảnh nguồn -> HEX -> simulation -> ảnh tái tạo.

## 7) Danh sách todo thực thi
1. Chuẩn hóa spec và interface tín hiệu cho toàn hệ thống.
2. Hoàn thiện `vga_timing` + verify timing.
3. Hoàn thiện memory/image pipeline (HEX format + address map).
4. Tích hợp top-level + cân chỉnh pipeline độ trễ.
5. Hoàn thiện testbench tổng + xuất frame kết quả.
6. Đối chiếu ảnh, lưu artifact, hoàn thiện hướng dẫn và báo cáo.
