$response = Invoke-RestMethod -Uri "http://127.0.0.1:8090/api/admins/auth-with-password" -Method POST -ContentType "application/json" -Body '{"identity":"admin@admin.com","password":"admin1234"}'

$token = $response.token

$body = @{
    createRule = "@request.auth.id != ''"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://127.0.0.1:8090/api/collections/notifications" -Method PATCH -Headers @{ Authorization = $token } -ContentType "application/json" -Body $body
