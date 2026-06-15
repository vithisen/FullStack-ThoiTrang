# Luồng thao tác (User Flow) của ứng dụng Shop Thời Trang

Tài liệu này liệt kê quá trình thao tác và luồng đi qua các màn hình hiện tại của ứng dụng. Khi có thêm giao diện mới, tài liệu này sẽ được cập nhật.

## 1. Luồng Xác thực (Authentication)
* **Khởi chạy ứng dụng** -> Hiển thị màn hình chính (Splash/Welcome - nếu có)
* **Đăng nhập / Đăng ký**:
  * Người dùng nhập thông tin và nhấn Đăng nhập (Login) hoặc Đăng ký (Sign Up).
  * (Nút "Or sign up with social account" nằm ở dưới cùng).
  * Sau khi Đăng nhập/Đăng ký thành công -> Chuyển hướng vào màn hình chính của ứng dụng (Main/Home).

## 2. Luồng Màn hình chính (Main / Home)
* **Main 1 (Trang chủ)**: Hiển thị các banner, sản phẩm nổi bật.
* **Main 2, Main 3**: Có thể vuốt ngang (slide show) để xem các nội dung khác.

## 3. Luồng Danh mục sản phẩm (Categories & Shopping)
* Từ menu/tab, chọn **Categories (Danh mục)** -> Hiển thị màn hình `Categories` (cate 1).
  * Chứa các danh mục lớn: New, Clothes, Shoes, Accessories.
* Click vào một danh mục (ví dụ: Clothes) -> Chuyển sang màn hình **Sub-Categories** (cate 2).
  * Nhận tham số tên danh mục (ví dụ: "Clothes") để hiển thị danh sách các mục con tương ứng (ví dụ: Áo thun, Áo khoác...).
* Click vào một mục con hoặc nút "View All Items" -> Chuyển sang màn hình **Catalog** (Danh sách sản phẩm).
  * Màn hình Catalog hiển thị danh sách các sản phẩm thuộc phân loại đó.
  * Có nút chuyển đổi chế độ hiển thị: Dạng danh sách dọc (List) hoặc Dạng lưới (Grid).
  * **Chi tiết sản phẩm (Product Detail)**: Tại màn hình Catalog, khi nhấn vào bất kỳ sản phẩm nào, người dùng sẽ chuyển tiếp sang màn hình **Product Detail Screen** (Chi tiết sản phẩm).
    * Hiển thị ảnh trượt ngang (Carousel), các dropdown chọn Size & Color, nút Yêu thích, thông tin nhãn hàng, mô tả sản phẩm.
    * Nhấn nút "ADD TO CART" để thêm sản phẩm vào giỏ hàng.
    * Xem thông tin giao hàng (Shipping info), hỗ trợ (Support).
    * Hiển thị danh sách sản phẩm liên quan gợi ý ở bên dưới cuộn ngang.
    * Nhấp vào khu vực đánh giá sao -> Chuyển hướng sang màn hình **Rating and Reviews** để xem chi tiết điểm đánh giá tổng quan, biểu đồ thống kê các mức sao, lọc bình luận có ảnh, và viết đánh giá mới.
  * **Bộ lọc (Filters)**: Tại màn hình Catalog, có nút "Filters". Bấm vào đây sẽ mở màn hình **Filters** để chọn khoảng giá, màu sắc, kích cỡ, danh mục và thương hiệu (Brand).
  * Trong màn hình Filters, khi nhấn vào mục **Brand**, ứng dụng chuyển sang màn hình **Brand Filter (Filters/List)** cho phép tìm kiếm và tích chọn các thương hiệu.

## 4. Luồng Danh sách Yêu thích (Favorites)
* Từ Bottom Navigation Bar, chọn **Favorites** (icon Trái tim) -> Chuyển sang màn hình **Favorites** (Danh sách Yêu thích).
  * Hỗ trợ hai chế độ hiển thị: Dạng danh sách dọc (List view) hoặc Dạng lưới (Grid view) chuyển đổi linh hoạt qua nút toggle trên thanh Filter Toolbar.
  * Hiển thị danh sách các sản phẩm đã lưu bao gồm: nhãn Tag (NEW/-30%), hãng, tên sản phẩm, màu sắc, kích cỡ, giá tiền (có giá gốc gạch ngang/giá khuyến mãi đỏ), đánh giá sao.
  * Có nút `x` ở góc trên cùng bên phải để xóa nhanh sản phẩm khỏi danh sách yêu thích.
  * Có nút icon Shopping Bag màu đỏ ở góc dưới bên phải (trên hình ảnh đối với Grid, hoặc ở góc thẻ đối với List) để thêm trực tiếp sản phẩm vào giỏ hàng (không áp dụng đối với sản phẩm đã hết hàng - "sold out").
  * Nếu sản phẩm hết hàng (sold out):
    * Ở dạng danh sách dọc (List view): Hiển thị thông báo phụ "Sorry, this item is currently sold out" ngay dưới thẻ sản phẩm.
    * Ở dạng lưới (Grid view): Hiển thị một lớp phủ mờ (grey overlay) với dòng chữ "Sorry, this item is currently sold out" nằm đè lên góc dưới của ảnh sản phẩm.
  * Nhấn vào nút Yêu thích (Trái tim) ở trang chủ:
    * Nếu sản phẩm chưa có trong danh sách yêu thích -> Hiển thị Bottom Sheet chọn kích cỡ (Select size) với nút **ADD TO FAVORITES** để người dùng chọn size trước khi lưu.
    * Nếu sản phẩm đã được lưu -> Nhấp lại để xóa nhanh khỏi danh sách yêu thích.

## 5. Luồng Giỏ hàng (My Bag / Cart)
* Từ Bottom Navigation Bar, chọn **Bag** (icon Giỏ hàng) -> Chuyển sang màn hình **My Bag** (Giỏ hàng).
  * Hiển thị danh sách các sản phẩm đang có trong giỏ hàng (ví dụ: Pullover, T-Shirt, Sport Dress) dưới dạng thẻ ngang.
  * Mỗi thẻ sản phẩm hiển thị: ảnh sản phẩm, tên, màu sắc, kích cỡ, bộ tăng giảm số lượng (`-` / `+`) và tổng giá tiền của sản phẩm đó tương ứng với số lượng.
  * Nhấp chọn nút ba chấm dọc ở góc trên phải của mỗi thẻ để mở **Popup Menu**:
    * Có 2 lựa chọn: **Add to favorites** (Thêm vào mục yêu thích) và **Delete from the list** (Xóa khỏi giỏ hàng).
  * Bấm nút `-` để giảm số lượng (nếu số lượng về 0 sẽ xóa sản phẩm khỏi giỏ hàng). Bấm nút `+` để tăng số lượng. Tổng số tiền sẽ tự động tính toán lại theo thời gian thực.
  * **Mã giảm giá (Promo Code)**:
    * Ở góc dưới danh sách có thanh nhập mã giảm giá "Enter your promo code" kèm nút mũi tên đen.
    * Bấm vào thanh này sẽ mở **Bottom Sheet chọn mã giảm giá (Promo Codes)**:
      * Cho phép gõ mã thủ công hoặc chọn áp dụng từ danh sách mã có sẵn (Personal offer 10%, Summer Sale 15%, Personal offer 22%).
      * Bấm **Apply** để áp dụng mã giảm giá, đóng Bottom sheet và hiển thị mã code lên ô nhập liệu. Khi mã được áp dụng, nút mũi tên đen sẽ chuyển thành biểu tượng chữ `x` để xóa/hủy áp dụng mã giảm giá.
      * Tổng số tiền thanh toán (Total amount) ở màn hình chính của Giỏ hàng sẽ được cập nhật giảm trừ tương ứng.
  * Bấm nút **CHECK OUT** ở dưới cùng để chuyển sang màn hình **Thanh toán (Checkout)**.

## 6. Luồng Thanh toán (Checkout)
* Từ màn hình Giỏ hàng, bấm nút **CHECK OUT** -> Chuyển sang màn hình **Checkout**.
  * **Shipping address (Địa chỉ giao hàng)**: Hiển thị địa chỉ mặc định (ví dụ: Jane Doe, Chino Hills...). Bấm "Change" để thay đổi địa chỉ.
  * **Payment (Phương thức thanh toán)**: Hiển thị thẻ thanh toán mặc định. Bấm "Change" để chuyển sang màn hình **Phương thức thanh toán (Payment methods)** nhằm chọn thẻ khác hoặc thêm thẻ mới. Khi chọn thẻ mặc định mới và quay lại, giao diện Checkout sẽ cập nhật thông tin thẻ tương ứng.
  * **Delivery method (Phương thức vận chuyển)**:
    * Chọn giữa 3 đối tác giao hàng: FedEx, USPS, DHL.
    * Giá vận chuyển thay đổi tương ứng (ví dụ: FedEx 15$, USPS 10$, DHL 20$). Khi chọn một phương thức, giá trị sẽ tự động cập nhật vào mục tính toán tổng số tiền.
  * **Tóm tắt hóa đơn (Totals Summary)**:
    * `Order`: Tiền hàng sau khi giảm trừ khuyến mãi.
    * `Delivery`: Tiền phí vận chuyển của đơn vị được chọn.
    * `Summary`: Tổng số tiền cần thanh toán thực tế (bằng Order + Delivery).
  * Bấm nút **SUBMIT ORDER** ở dưới cùng để hoàn tất đặt hàng.

## 7. Luồng Phương thức thanh toán (Payment methods)
* Từ màn hình Checkout, bấm "Change" ở mục Payment -> Chuyển sang màn hình **Payment methods**.
  * Hiển thị danh sách các thẻ tín dụng đã liên kết (Mastercard đen, Visa xám) được thiết kế chân thực với chip vàng, số thẻ ẩn, tên chủ thẻ và ngày hết hạn.
  * Mỗi thẻ có checkbox "Use as default payment method" để chọn làm thẻ thanh toán mặc định.
  * Bấm nút **+** (Floating Action Button) ở góc dưới phải để mở **Bottom Sheet thêm thẻ mới (Add new card)**:
    * Người dùng nhập: Tên chủ thẻ, số thẻ, ngày hết hạn (MM/YY), mã bảo mật CVV.
    * Có tùy chọn checkbox "Set as default payment method".
    * Bấm **ADD CARD** để xác thực thông tin và tự động nhận diện loại thẻ (Visa nếu số thẻ bắt đầu bằng 4, Mastercard cho các đầu số khác), thêm thẻ mới vào danh sách.
  * Khi nhấn nút Back quay lại màn hình Checkout, thông tin thẻ mặc định được chọn sẽ tự động cập nhật hiển thị theo thời gian thực.

## 8. Luồng Sổ địa chỉ giao hàng (Shipping Addresses)
* Từ màn hình Checkout, bấm "Change" ở mục Shipping address -> Chuyển sang màn hình **Shipping Addresses** (Sổ địa chỉ giao hàng).
  * Hiển thị danh sách các địa chỉ giao hàng khả dụng dưới dạng các thẻ trắng bo góc, đổ bóng nhẹ.
  * Mỗi thẻ hiển thị Tên người nhận, địa chỉ chi tiết, nút **Edit** để sửa địa chỉ và checkbox "Use as the shipping address" để thay đổi địa chỉ mặc định giao hàng.
  * Tích chọn một địa chỉ bất kỳ và quay về (Back) sẽ tự động đồng bộ và hiển thị địa chỉ đó trên màn hình Checkout.
  * Bấm nút **+** (Floating Action Button đen tròn) ở góc dưới phải để mở màn hình **Adding Shipping Address** (Thêm địa chỉ mới):
    * Người dùng nhập: Họ tên, địa chỉ, thành phố, bang/tỉnh, mã bưu điện (Zip Code), quốc gia (Country - bấm chọn từ danh sách quốc gia qua bottom sheet).
    * Nhấn nút **SAVE ADDRESS** để xác thực thông tin và lưu địa chỉ mới vào danh sách.
  * Bấm nút **Edit** trên thẻ địa chỉ bất kỳ để mở màn hình sửa địa chỉ với các thông tin cũ được tự động điền sẵn. Chỉnh sửa và nhấn **SAVE ADDRESS** để cập nhật dữ liệu.

## 9. Luồng Đơn hàng Thành công (Order Success)
* Từ màn hình Checkout, bấm nút **SUBMIT ORDER** -> Chuyển sang màn hình **Order Success** (Đặt hàng thành công).
  * Hiển thị hình vẽ minh họa 2 chiếc túi mua sắm (đỏ & vàng) cùng pháo hoa confetti lơ lửng.
  * Hiển thị tiêu đề `Success!` và dòng phụ đề chúc mừng.
  * Bấm nút **CONTINUE SHOPPING** ở dưới cùng để quay lại màn hình Trang chủ của ứng dụng và xóa toàn bộ lịch sử điều hướng trước đó (để nút Back của điện thoại không quay lại trang checkout nữa).

## 10. Luồng Hồ sơ cá nhân (My Profile)
* Từ Bottom Navigation Bar, chọn **Profile** -> Chuyển sang màn hình **My Profile**.
  * Hiển thị thông tin cá nhân của người dùng gồm ảnh đại diện tròn, họ tên (Matilda Brown) và email.
  * Danh sách các mục tùy chọn điều hướng:
    - **My orders**: Bấm chuyển hướng sang màn hình **Danh sách đơn hàng** `/my_orders`.
    - **Shipping addresses**: Bấm chuyển hướng nhanh sang Sổ địa chỉ `/shipping_addresses`.
    - **Payment methods**: Bấm chuyển hướng nhanh sang Quản lý thẻ `/payment_methods`.
    - **Promocodes**: Xem danh sách mã giảm giá.
    - **My reviews**: Xem danh sách đánh giá của tôi.
    - **Settings**: Bấm chuyển hướng sang màn hình **Cài đặt** `/settings`.

## 11. Luồng Lịch sử Đơn hàng (My Orders & Order Details)
* Từ màn hình Profile, bấm **My orders** -> Chuyển sang màn hình **My Orders** (Đơn hàng của tôi).
  * Cho phép lọc nhanh đơn hàng theo 3 trạng thái: `Delivered` (Đã giao), `Processing` (Đang xử lý), `Cancelled` (Đã hủy).
  * Mỗi thẻ đơn hàng hiển thị mã đơn, ngày đặt, mã tracking, số lượng sản phẩm, tổng giá trị và nút **Details**.
  * Bấm nút **Details** (hoặc nhấp vào thẻ) -> Chuyển tiếp sang màn hình **Order Details** (Chi tiết đơn hàng).
    - Hiển thị đầy đủ thông tin mã đơn, ngày đặt, tracking, trạng thái.
    - Liệt kê chi tiết các sản phẩm trong đơn (ảnh, tên, hãng, màu, size, số lượng, giá tiền).
    - Khối `Order information` tóm tắt địa chỉ giao hàng, phương thức thanh toán (logo Mastercard vẽ trực quan), đơn vị vận chuyển, mã giảm giá áp dụng và tổng số tiền thanh toán thực tế.
    - Hai nút ở dưới cùng: **Reorder** (Mua lại) và **Leave feedback** (Đánh giá - chuyển hướng sang `/rating_reviews`).

## 12. Luồng Cài đặt & Thay đổi Mật khẩu (Settings & Password Change)
* Từ màn hình Profile, bấm **Settings** -> Chuyển sang màn hình **Settings** (Cài đặt).
  * Cho phép xem và chỉnh sửa thông tin cá nhân: Full name, Date of Birth.
  * Hiển thị mật khẩu ẩn, bấm **Change** ở góc phải tiêu đề Password sẽ mở **Password Change Bottom Sheet** (Thay đổi mật khẩu):
    - Người dùng nhập: Mật khẩu cũ (Old Password), Mật khẩu mới (New Password), Nhập lại mật khẩu mới (Repeat New Password).
    - Tích hợp liên kết **Forgot Password?** dưới trường Old Password để chuyển hướng sang màn hình Quên mật khẩu `/forgot_password`.
    - Bấm **SAVE PASSWORD** để kiểm tra tính hợp lệ và cập nhật mật khẩu mới.
  * Hỗ trợ cài đặt nhận thông báo thông qua 3 cần gạt (Switch) Toggle: `Sales`, `New arrivals`, `Delivery status changes`.

---
*Lưu ý: Luồng này sẽ được cập nhật liên tục khi phát triển thêm các tính năng và giao diện mới.*

