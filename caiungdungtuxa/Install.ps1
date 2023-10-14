# Đường dẫn tới tệp CSV chứa thông tin người dùng và ứng dụng
$csvFilePath = "C:\Temp\danhsachcaidat.csv"

# Tải danh sách người dùng và ứng dụng từ tệp CSV
$ClientList = Import-Csv $csvFilePath

foreach ($Client in $ClientList) {
    # Lấy tên máy client từ cột ComputerName
    $ComputerName = $Client.ComputerName
    
    # Lấy tên User
    $Users = $Client.User

    # Lấy danh sách ứng dụng cần cài đặt từ cột Applications và chuyển chúng thành mảng (nếu chúng được liệt kê trong cùng một ô)
    $Applications = $Client.Applications -split ','

    foreach ($ApplicationName in $Applications) {
        # Kiểm tra xem ứng dụng có tồn tại trong thư mục ổ C:\Software hay không
        $ApplicationPath = "C:\Software\$ApplicationName.exe"

        if (Test-Path $ApplicationPath) {
            # Sao chép ứng dụng từ thư mục "C:\Software" lên Desktop của máy tính mục tiêu
            $DestinationPath = "\\$ComputerName\$Users\$ApplicationName.exe"
            Copy-Item -Path $ApplicationPath -Destination $DestinationPath -Force

            Write-Host "Ung dung $ApplicationName da duoc sao chep len Desktop cua may $ComputerName - $Users"
        } else {
            Write-Host "Ung dung $ApplicationName khong ton tai trong thư muc o C:\Software tren may $ComputerName-$Users"
        }
    }
}