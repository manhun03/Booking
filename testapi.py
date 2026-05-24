from langchain_core.tools import tool
from call_api import _call_api, _format_items


@tool
def search_hotels(page_index: int, page_size: int) -> str:
    """Tìm kiếm toàn bộ khách sạn đang có trong API.
    Args:
        page_index (int): Chỉ số trang
        page_size (int): Số lượng khách sạn trên mỗi trang
    Returns:
        Danh sách các khách sạn bao gồm tên, địa chỉ, số điện thoại và đánh giá.
        Nếu không tìm thấy khách sạn nào, trả về thông báo phù hợp.
    """
    result = _call_api(
        "hotels/all-with-province",
        params={
            "pageIndex": page_index,
            "pageSize": page_size
        }
    )

    if not result["success"]:
        return result["error"]

    api_data = result["data"]

    # JSON của ASP.NET Core bạn
    # data → dict → data → list
    if isinstance(api_data, dict):

        data_block = api_data.get("data", {})

        if isinstance(data_block, dict):
            hotels = data_block.get("data", [])
        else:
            hotels = data_block

    else:
        hotels = []

    if not hotels:
        return "Không có khách sạn nào."

    return _format_items(
        hotels,
        [
            "id",
            "name",
            "provinceName",
            "wardName",
            "street",
            "phone",
            "description",
            "status"
        ]
    )
@tool
def search_hotelsbyname(hotelName: str) -> str:
    """Tìm kiếm khách sạn theo tên của khách sạn.
    Args:
        hotelName (str): Tên khách sạn cần tìm
    Returns:
        Danh sách các khách sạn phù hợp bao gồm tên, địa chỉ, số điện thoại và đánh giá.
        Nếu không tìm thấy khách sạn nào, trả về thông báo phù hợp.
    """
    result = _call_api(
        "hotels/search",
        params={
            "hotelName": hotelName
        }
    )
    if not result["success"]:
        return result["error"]
    api_data = result["data"]
    if isinstance(api_data, dict):
        data_block = api_data.get("data", {})
        if isinstance(data_block, dict):
            hotels = data_block.get("hotels", [])
        else:
            hotels = data_block
    else:
        hotels = []
    if not hotels:
        return "Không tìm thấy khách sạn nào"
    return _format_items(
        hotels,
        [
            "id",
            "name",
            "provinceName",
            "wardName",
            "street",
            "phone",
            "description",
            "status"
        ]
    )
@tool
def search_hotelsbyprovince(province: str) -> str:
    """Tìm kiếm khách sạn theo tỉnh/thành phố.
    Args:
        province (str): Truyền vào tên tỉnh/thành phố cần tìm kiếm khách sạn
    Returns:
        Danh sách các khách sạn phù hợp bao gồm tên, địa chỉ, số điện thoại và đánh giá.
        Nếu không tìm thấy khách sạn nào, trả về thông báo phù hợp.
    """
    result = _call_api(
        "hotels/by-province",
        params={
            "province": province
        }
    )
    if not result["success"]:
        return result["error"]
    api_data = result["data"]
    if isinstance(api_data, dict):
        data_block = api_data.get("data", {})
        if isinstance(data_block, dict):
            hotels = data_block.get("hotels", [])
        else:
            hotels = data_block
    else:
        hotels = []
    if not hotels:
        return "Không tìm thấy khách sạn nào"
    return _format_items(
        hotels,
        [
            "id",
            "name",
            "provinceName",
            "wardName",
            "street",
            "phone",
            "description",
            "status"
        ]
    )


@tool
def search_roomtypebyHotelID(hotelId: int) -> str:
    """Tìm kiếm loại phòng theo ID khách sạn.
    Args:
        hotelId (int): ID của khách sạn
    Returns:
        Danh sách các loại phòng phù hợp bao gồm tên, mô tả và thông tin chi tiết từng rooms trong roomtypes.
        Nếu không tìm thấy khách sạn nào, trả về thông báo phù hợp.
    """
    result = _call_api(
        "room-types/by-hotel",
        params={
            "hotelId": hotelId
        }
    )
    if not result["success"]:
        return result["error"]
    api_data = result["data"]
    if isinstance(api_data, dict):
        data_block = api_data.get("data", {})
        if isinstance(data_block, dict):
            roomtype_data = data_block.get("data", [])
        else:
            roomtype_data = data_block
    else:
        roomtype_data = []
    if not roomtype_data:
        return "Không có phòng nào"
    return _format_items(
        roomtype_data,
        [
            "id",
            "name",
            "description",
            "rooms"
        ]

    )
