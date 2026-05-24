import os
from urllib.parse import urljoin
import requests
API_BASE_URL = os.getenv("TRAVEL_API_BASE_URL", "http://localhost:5146/api")

def _call_api(endpoint: str, params: dict) -> object:
    url = urljoin(API_BASE_URL.rstrip("/") + "/", endpoint.lstrip("/"))
    try:
        response = requests.get(url, params={k: v for k, v in params.items() if v is not None and v != ""}, timeout=10)
        response.raise_for_status()
    except requests.RequestException as e:
        return {
            "success": False,
            "error": f"Lỗi khi gọi API {url}: {e}",
        }

    try:
        return {
            "success": True,
            "data": response.json(),
        }
    except ValueError:
        return {
            "success": False,
            "error": "Lỗi: API trả về dữ liệu không phải JSON.",
        }


def _format_items(items: list[dict], fields: list[str]) -> str:
    if not items:
        return "Không tìm thấy kết quả phù hợp."

    lines = []
    for item in items:
        parts = []
        for field in fields:
            if field in item and item[field] is not None:
                parts.append(f"{field}: {item[field]}")
        lines.append(" | ".join(parts))
    return "\n".join(lines)