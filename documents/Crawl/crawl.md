## BƯỚC 1: Cài Đặt Thư Viện

Mở Terminal/CMD và chạy:

```bash
pip install requests beautifulsoup4 lxml
```

| Thư viện | Làm gì? |
|----------|---------|
| `requests` | Gửi request tới website, lấy HTML về |
| `beautifulsoup4` | Đọc HTML, tìm thẻ, lấy nội dung |
| `lxml` | Parser nhanh cho BeautifulSoup |

---

## BƯỚC 2: Hiểu Cách Crawl Hoạt Động

```
Bạn (Python)          Website
    │                    │
    │── GET request ────►│   "Cho tôi xem trang này"
    │◄── HTML response ──│   Website trả về HTML
    │                    │
    ▼
Đọc HTML, tìm thẻ <div>, <span>, <a>...
    │
    ▼
Lấy text, link, hình ảnh... → Lưu file
```

---

## BƯỚC 3: Code Mẫu Cơ Bản

### 3.1 Lấy HTML từ website

```python
import requests

# Gửi request lấy HTML
url = "https://example.com"
response = requests.get(url)

# Kiểm tra thành công chưa
if response.status_code == 200:
    html = response.text
    print("Lấy HTML thành công!")
    print(html[:500])  # In 500 ký tự đầu
else:
    print(f"Lỗi: {response.status_code}")
```

### 3.2 Đọc HTML với BeautifulSoup

```python
from bs4 import BeautifulSoup

# Parse HTML
soup = BeautifulSoup(html, 'lxml')

# Lấy title trang
title = soup.title.text
print(f"Tiêu đề: {title}")

# Lấy tất cả thẻ <a> (link)
links = soup.find_all('a')
for link in links:
    print(link.get('href'))  # In ra href
    print(link.text)         # In ra text
```

---

## BƯỚC 4: Các Cách Tìm Thẻ HTML

### 4.1 Tìm theo tên thẻ

```python
# Tìm 1 thẻ đầu tiên
h1 = soup.find('h1')
print(h1.text)

# Tìm tất cả thẻ
all_p = soup.find_all('p')
for p in all_p:
    print(p.text)
```

### 4.2 Tìm theo class

```python
# HTML: <div class="product-name">iPhone 15</div>

# Cách 1: dùng class_
product = soup.find('div', class_='product-name')
print(product.text)  # iPhone 15

# Cách 2: dùng attrs
product = soup.find('div', attrs={'class': 'product-name'})
```

### 4.3 Tìm theo id

```python
# HTML: <div id="main-content">Nội dung chính</div>

content = soup.find('div', id='main-content')
print(content.text)
```

### 4.4 Tìm theo CSS Selector (giống jQuery)

```python
# Tìm theo class
items = soup.select('.product-item')

# Tìm theo id
header = soup.select_one('#header')

# Tìm lồng nhau: div có class "list" > thẻ a
links = soup.select('div.list a')

# Tìm theo attribute
images = soup.select('img[src]')
```

---

## BƯỚC 5: Lấy Dữ Liệu Từ Thẻ

```python
# Giả sử có HTML như này:
# <a href="https://example.com" class="link" title="Example">Click here</a>

link = soup.find('a', class_='link')

# Lấy text bên trong
text = link.text                    # "Click here"
text = link.get_text(strip=True)    # "Click here" (bỏ khoảng trắng)

# Lấy attribute
href = link.get('href')             # "https://example.com"
href = link['href']                 # Cách khác
title = link.get('title')           # "Example"

# Lấy tất cả attributes
attrs = link.attrs                  # {'href': '...', 'class': [...], 'title': '...'}
```

---

## BƯỚC 6: Ví Dụ Thực Tế - Crawl Sản Phẩm

```python
import requests
from bs4 import BeautifulSoup

def crawl_products(url):
    """Crawl danh sách sản phẩm từ website"""
    
    # 1. Gửi request
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0'
    }
    response = requests.get(url, headers=headers)
    
    # 2. Parse HTML
    soup = BeautifulSoup(response.text, 'lxml')
    
    # 3. Tìm tất cả sản phẩm
    products = []
    items = soup.select('.product-item')  # Selector tùy website
    
    for item in items:
        product = {
            'name': item.select_one('.product-name').text.strip(),
            'price': item.select_one('.product-price').text.strip(),
            'image': item.select_one('img').get('src'),
            'link': item.select_one('a').get('href')
        }
        products.append(product)
    
    return products

# Sử dụng
data = crawl_products('https://example.com/products')
for p in data:
    print(f"{p['name']} - {p['price']}")
```

---

## BƯỚC 7: Xử Lý Phân Trang (Pagination)

```python
import time

def crawl_all_pages(base_url, total_pages):
    """Crawl nhiều trang"""
    
    all_products = []
    
    for page in range(1, total_pages + 1):
        url = f"{base_url}?page={page}"
        print(f"Đang crawl trang {page}...")
        
        products = crawl_products(url)
        all_products.extend(products)
        
        # QUAN TRỌNG: Nghỉ 1-2 giây giữa mỗi request
        time.sleep(2)
    
    return all_products

# Sử dụng
all_data = crawl_all_pages('https://example.com/products', total_pages=10)
print(f"Tổng: {len(all_data)} sản phẩm")
```

---

## BƯỚC 8: Lưu Dữ Liệu

### 8.1 Lưu JSON

```python
import json

def save_json(data, filename):
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Đã lưu {len(data)} items vào {filename}")

# Sử dụng
save_json(all_data, 'products.json')
```

### 8.2 Lưu CSV

```python
import csv

def save_csv(data, filename):
    if not data:
        return
    
    keys = data[0].keys()
    with open(filename, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=keys)
        writer.writeheader()
        writer.writerows(data)
    print(f"Đã lưu {len(data)} items vào {filename}")

# Sử dụng
save_csv(all_data, 'products.csv')
```

### 8.3 Lưu Excel (cần cài pandas)

```python
# pip install pandas openpyxl
import pandas as pd

def save_excel(data, filename):
    df = pd.DataFrame(data)
    df.to_excel(filename, index=False)
    print(f"Đã lưu {len(data)} items vào {filename}")

# Sử dụng
save_excel(all_data, 'products.xlsx')
```

---

## BƯỚC 9: Xử Lý Các Vấn Đề Thường Gặp

### 9.1 Website chặn bot → Thêm Headers

```python
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0',
    'Accept': 'text/html,application/xhtml+xml',
    'Accept-Language': 'vi-VN,vi;q=0.9,en;q=0.8',
    'Referer': 'https://google.com'
}

response = requests.get(url, headers=headers)
```

### 9.2 Bị timeout → Thêm timeout

```python
try:
    response = requests.get(url, headers=headers, timeout=10)
except requests.Timeout:
    print("Request timeout!")
except requests.RequestException as e:
    print(f"Lỗi: {e}")
```

### 9.3 Không tìm thấy element → Kiểm tra None

```python
element = soup.select_one('.product-name')

# Cách an toàn
if element:
    name = element.text.strip()
else:
    name = "Không có"

# Cách ngắn gọn
name = element.text.strip() if element else "Không có"
```

### 9.4 Website dùng JavaScript → Dùng Selenium

```python
# pip install selenium webdriver-manager

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

# Mở trình duyệt
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))

# Truy cập trang
driver.get('https://example.com')

# Chờ 3 giây để JavaScript load
import time
time.sleep(3)

# Lấy HTML sau khi JavaScript chạy xong
html = driver.page_source

# Parse như bình thường
soup = BeautifulSoup(html, 'lxml')

# Đóng trình duyệt
driver.quit()
```

---

## BƯỚC 10: Code Hoàn Chỉnh (Copy & Sửa)

```python

import requests
from bs4 import BeautifulSoup
import json
import time

class Crawler:
    def __init__(self):
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0'
        }
        self.delay = 2  # Nghỉ 2 giây giữa mỗi request
    
    def get_html(self, url):
        """Lấy HTML từ URL"""
        try:
            response = requests.get(url, headers=self.headers, timeout=10)
            response.raise_for_status()
            return response.text
        except Exception as e:
            print(f"Lỗi khi lấy {url}: {e}")
            return None
    
    def parse_page(self, html):
        """Parse HTML và trích xuất dữ liệu"""
        soup = BeautifulSoup(html, 'lxml')
        items = []
        
        # ===== SỬA PHẦN NÀY THEO WEBSITE BẠN CRAWL =====
        for item in soup.select('.product-item'):
            data = {
                'name': self.safe_get_text(item, '.product-name'),
                'price': self.safe_get_text(item, '.product-price'),
                'image': self.safe_get_attr(item, 'img', 'src'),
                'link': self.safe_get_attr(item, 'a', 'href'),
            }
            items.append(data)
        # ================================================
        
        return items
    
    def safe_get_text(self, parent, selector):
        """Lấy text an toàn, tránh lỗi None"""
        el = parent.select_one(selector)
        return el.text.strip() if el else ""
    
    def safe_get_attr(self, parent, selector, attr):
        """Lấy attribute an toàn"""
        el = parent.select_one(selector)
        return el.get(attr, "") if el else ""
    
    def crawl(self, urls):
        """Crawl danh sách URLs"""
        all_data = []
        
        for i, url in enumerate(urls):
            print(f"[{i+1}/{len(urls)}] Crawling: {url}")
            
            html = self.get_html(url)
            if html:
                data = self.parse_page(html)
                all_data.extend(data)
                print(f"  → Lấy được {len(data)} items")
            
            time.sleep(self.delay)
        
        return all_data
    
    def save(self, data, filename):
        """Lưu dữ liệu ra file JSON"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"\n Đã lưu {len(data)} items vào {filename}")


#CHẠY CRAWLER
if __name__ == "__main__":
    crawler = Crawler()
    
    # Danh sách URLs cần crawl
    urls = [
        'https://example.com/products?page=1',
        'https://example.com/products?page=2',
        'https://example.com/products?page=3',
    ]
    
    # Crawl và lưu
    data = crawler.crawl(urls)
    crawler.save(data, 'data.json')
```

---

## BƯỚC 11: Cách Tìm Selector

### Mở Developer Tools (F12)

1. Vào website bạn muốn crawl
2. Nhấn `F12` hoặc `Chuột phải → Inspect`
3. Click icon mũi tên (góc trái trên)
4. Di chuột vào element muốn lấy
5. Xem class, id trong tab Elements

### Ví dụ

```html
<!-- Bạn thấy HTML như này trong DevTools -->
<div class="product-card">
    <h3 class="product-title">iPhone 15 Pro</h3>
    <span class="price-current">25.990.000đ</span>
    <img src="https://..." alt="iPhone">
</div>
```

```python
# Code Python tương ứng
items = soup.select('.product-card')
for item in items:
    name = item.select_one('.product-title').text
    price = item.select_one('.price-current').text
    img = item.select_one('img').get('src')
```
