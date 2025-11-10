const String stationListJson = '''
  {
    "data": [
        {
            "stationId": 1,
            "avatar": "https://placehold.co/100x100/7B1FA2/FFFFFF?text=S1",
            "stationCode": "ST_001_HCM",
            "stationName": "Bida Station Quận 1",
            "address": "123 Nguyễn Huệ, P. Bến Nghé, Q.1, TP. Hồ Chí Minh",
            "province": "TP. Hồ Chí Minh",
            "commune": "P. Bến Nghé",
            "district": "Quận 1",
            "hotline": "0901111111",
            "statusCode": "ENABLE",
            "statusName": "Kích hoạt",
            "media": [
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                },
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                }
            ],
            "metadata": null
        },
        {
            "stationId": 2,
            "avatar": "https://placehold.co/100x100/F57C00/FFFFFF?text=S2",
            "stationCode": "ST_002_HN",
            "stationName": "Net Cầu Giấy (Chờ duyệt)",
            "address": "456 Xuân Thủy, Dịch Vọng Hậu, Cầu Giấy, Hà Nội",
            "province": "Hà Nội",
            "commune": "Dịch Vọng Hậu",
            "district": "Cầu Giấy",
            "hotline": "0902222222",
            "statusCode": "PENDING",
            "statusName": "Chờ duyệt",
            "media": [
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                }
            ],
            "metadata": null
        },
        {
            "stationId": 3,
            "avatar": "https://placehold.co/100x100/D32F2F/FFFFFF?text=S3",
            "stationCode": "ST_003_DN",
            "stationName": "PlayStation Cẩm Lệ (Bị từ chối)",
            "address": "789 Phan Văn Trị, Khuê Trung, Cẩm Lệ, Đà Nẵng",
            "province": "Đà Nẵng",
            "commune": "Khuê Trung",
            "district": "Cẩm Lệ",
            "hotline": "0903333333",
            "statusCode": "REJECTED",
            "statusName": "Bị từ chối",
            "media": [],
            "metadata": {
                "rejectReason": "Thiếu hình ảnh thực tế của cơ sở.",
                "rejectAt": "2025-11-04T09:46:30.778Z"
            }
        },
        {
            "stationId": 4,
            "avatar": "https://placehold.co/100x100/1976D2/FFFFFF?text=S4",
            "stationCode": "ST_004_HCM",
            "stationName": "Bida Lỗ Quận 10",
            "address": "111 Tô Hiến Thành, P.14, Q.10, TP. Hồ Chí Minh",
            "province": "TP. Hồ Chí Minh",
            "commune": "P.14",
            "district": "Quận 10",
            "hotline": "0904444444",
            "statusCode": "ENABLE",
            "statusName": "Kích hoạt",
            "media": [
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                }
            ],
            "metadata": null
        },
        {
            "stationId": 5,
            "avatar": "https://placehold.co/100x100/388E3C/FFFFFF?text=S5",
            "stationCode": "ST_005_HN",
            "stationName": "Cyber Gaming Hà Đông",
            "address": "222 Quang Trung, Hà Đông, Hà Nội",
            "province": "Hà Nội",
            "commune": "Quang Trung",
            "district": "Hà Đông",
            "hotline": "0905555555",
            "statusCode": "ENABLE",
            "statusName": "Kích hoạt",
            "media": [
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                },
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                }
            ],
            "metadata": null
        },
        {
            "stationId": 6,
            "avatar": "https://placehold.co/100x100/757575/FFFFFF?text=S6",
            "stationCode": "ST_006_DN",
            "stationName": "Bida Thanh Khê (Bị khóa)",
            "address": "333 Lê Duẩn, Thanh Khê, Đà Nẵng",
            "province": "Đà Nẵng",
            "commune": "Tân Chính",
            "district": "Thanh Khê",
            "hotline": "0906666666",
            "statusCode": "LOCKED",
            "statusName": "Bị khóa",
            "media": [
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                }
            ],
            "metadata": null
        },
        {
            "stationId": 7,
            "avatar": "https://placehold.co/100x100/0097A7/FFFFFF?text=S7",
            "stationCode": "ST_007_HCM",
            "stationName": "PS5 Club Gò Vấp",
            "address": "777 Phan Văn Trị, P.7, Gò Vấp, TP. Hồ Chí Minh",
            "province": "TP. Hồ Chí Minh",
            "commune": "P.7",
            "district": "Gò Vấp",
            "hotline": "0907777777",
            "statusCode": "ENABLE",
            "statusName": "Kích hoạt",
            "media": [],
            "metadata": null
        },
        {
            "stationId": 8,
            "avatar": "https://placehold.co/100x100/F57C00/FFFFFF?text=S8",
            "stationCode": "ST_008_HCM",
            "stationName": "Net Bình Thạnh (Chờ duyệt)",
            "address": "888 Xô Viết Nghệ Tĩnh, P.25, Bình Thạnh, TP. Hồ Chí Minh",
            "province": "TP. Hồ Chí Minh",
            "commune": "P.25",
            "district": "Bình Thạnh",
            "hotline": "0908888888",
            "statusCode": "PENDING",
            "statusName": "Chờ duyệt",
            "media": [
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                }
            ],
            "metadata": null
        },
        {
            "stationId": 9,
            "avatar": "https://placehold.co/100x100/7B1FA2/FFFFFF?text=S9",
            "stationCode": "ST_009_HN",
            "stationName": "Bida Đống Đa",
            "address": "999 Chùa Láng, Láng Thượng, Đống Đa, Hà Nội",
            "province": "Hà Nội",
            "commune": "Láng Thượng",
            "district": "Đống Đa",
            "hotline": "0909999999",
            "statusCode": "ENABLE",
            "statusName": "Kích hoạt",
            "media": [
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                }
            ],
            "metadata": null
        },
        {
            "stationId": 10,
            "avatar": "https://placehold.co/100x100/D32F2F/FFFFFF?text=S10",
            "stationCode": "ST_010_DN",
            "stationName": "PS5 Hải Châu (Bị từ chối)",
            "address": "1010 Ông Ích Khiêm, Hải Châu, Đà Nẵng",
            "province": "Đà Nẵng",
            "commune": "Tân Lập",
            "district": "Hải Châu",
            "hotline": "0910101010",
            "statusCode": "REJECTED",
            "statusName": "Bị từ chối",
            "media": [
                {
                    "url": "https://firebasestorage.googleapis.com/v0/b/realmen-2023.appspot.com/o/Logo_No_Brand.png?alt=media&token=c505d2b2-88f8-46dc-a3f0-7b72731688ca"
                }
            ],
            "metadata": {
                "rejectReason": "Giấy phép kinh doanh không hợp lệ.",
                "rejectAt": "2025-11-03T09:46:30.778Z"
            }
        }
    ],
    "meta": {
        "pageSize": 10,
        "current": 1,
        "total": 10
    },
    "status": "200",
    "success": true,
    "errorCode": null,
    "responseAt": "2025-11-05T09:46:30.778699295",
    "message": "Dịch vụ đã được thực hiện"
}
  ''';
