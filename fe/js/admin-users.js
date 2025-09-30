// Admin Users JavaScript Module
// Extracted from admin-users.html for better code organization

// Admin header initialization function
function adminHeaderInit() {
  const u = (() => { 
    try { return JSON.parse(localStorage.getItem('user') || 'null'); } 
    catch { return null; } 
  })();
  
  const nameEl = document.getElementById('adminUserName');
  if (nameEl) nameEl.textContent = (u && u.full_name) ? u.full_name : 'Khách';
  
  const btnLogout = document.getElementById('btnLogout');
  if (btnLogout) {
    btnLogout.addEventListener('click', () => { 
      localStorage.clear(); 
      window.location.href = 'login.html'; 
    });
  }
  
  const path = (location.pathname || '').toLowerCase();
  document.querySelectorAll('.admin-nav a[data-nav]').forEach(a => {
    const key = a.getAttribute('data-nav');
    if ((key === 'products' && path.endsWith('admin-products.html')) || 
        (key === 'users' && path.endsWith('admin-users.html'))) {
      a.classList.add('active');
    }
  });
}

// API Management
let API_BASE = null;

function candidateBases() {
  const prot = location.protocol.startsWith('http') ? location.protocol : 'http:';
  const host = location.hostname || 'localhost';
  return [
    `${prot}//localhost/ecommerce_api/index.php/api`,
    `${prot}//127.0.0.1/ecommerce_api/index.php/api`,
    `${prot}//${host}/ecommerce_api/index.php/api`,
  ];
}

async function resolveApiBase() {
  console.log('Resolving API base...');
  
  for (const base of candidateBases()) {
    try {
      console.log('Trying base:', base);
      const testUrl = `${base}/users?limit=1`;
      const res = await fetch(testUrl, { 
        headers: authHeaders(),
        signal: AbortSignal.timeout(2000)
      });
      
      if (res.ok || res.status === 401 || res.status === 403) {
        // OK, 401 hoặc 403 đều có nghĩa endpoint tồn tại
        API_BASE = base;
        console.log('API_BASE resolved to:', API_BASE);
        return base;
      }
    } catch (e) { 
      console.log('Failed for base:', base, e.message);
    }
  }
  
  // Fallback
  API_BASE = `http://localhost/ecommerce_api/index.php/api`;
  console.log('Using fallback API_BASE:', API_BASE);
  return API_BASE;
}

// Authentication & State
const token = localStorage.getItem('token');
const user = (() => { 
  try { return JSON.parse(localStorage.getItem('user') || 'null'); } 
  catch { return null; } 
})();
const canWrite = !!token; // server enforces permissions

let currentPage = 1;
const pageSize = 10;
let lastCount = 0;
let cachedPage = [];

// Utility functions
function authHeaders() {
  const h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };
  if (token) h['Authorization'] = 'Bearer ' + token;
  return h;
}

function showMessage(msg, isError = false) {
  const style = isError ? 'background:#dc3545;color:#fff' : 'background:#28a745;color:#000';
  const div = document.createElement('div');
  div.style.cssText = `position:fixed;top:20px;right:20px;padding:12px 16px;border-radius:6px;z-index:9999;${style}`;
  div.textContent = msg;
  document.body.appendChild(div);
  setTimeout(() => div.remove(), 2800);
}

function redirectToLogin() {
  try {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  } catch {}
  showMessage('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại', true);
  setTimeout(() => {
    window.location.href = 'login.html';
  }, 900);
}

function isExpiredMessage(txt, data) {
  const m1 = typeof txt === 'string' && /(token\s+has\s+expired|expired\s+token)/i.test(txt);
  const msg = (data && (data.message || data.error || '')) || '';
  const m2 = typeof msg === 'string' && /(token\s+has\s+expired|expired\s+token)/i.test(msg);
  return !!(m1 || m2);
}

function handleUnauthorized(res, txt, data) {
  if (res && res.status === 401) {
    if (isExpiredMessage(txt, data)) redirectToLogin();
    else showMessage('Không có quyền hoặc cần đăng nhập lại', true);
    return true;
  }
  return false;
}

function updatePagination() {
  document.getElementById('pageLabel').textContent = `Trang ${currentPage}`;
  document.getElementById('btnPrev').disabled = currentPage <= 1;
  document.getElementById('btnNext').disabled = lastCount < pageSize;
}

// User filtering and rendering
function filterLocal() {
  const q = document.getElementById('txtSearch').value.trim().toLowerCase();
  const tbody = document.querySelector('#tblUsers tbody');
  const items = cachedPage.filter(u => {
    if (!q) return true;
    return (u.full_name || '').toLowerCase().includes(q) || 
           (u.email || '').toLowerCase().includes(q);
  });
  
  if (!items.length) {
    tbody.innerHTML = '<tr><td colspan="7" class="empty">Không có người dùng phù hợp</td></tr>';
    return;
  }
  tbody.innerHTML = items.map(renderRow).join('');
}

function renderRow(u) {
  const roles = (u.roles || '').split(',').filter(Boolean).join(', ');
  const status = (u.is_active === 0 || u.is_active === '0' || u.is_active === false) ? 
    '<span class="tag" style="border-color:#884;color:#c99">Inactive</span>' : 
    '<span class="tag" style="border-color:#484;color:#9f9">Active</span>';
  const editDisabled = canWrite ? '' : 'disabled';
  const delDisabled = canWrite ? '' : 'disabled';
  
  return `<tr>
    <td><strong>${u.id}</strong></td>
    <td>${u.full_name || ''}</td>
    <td>${u.email || ''}</td>
    <td>${u.phone || ''}</td>
    <td>${roles || ''}</td>
    <td>${status}</td>
    <td>
      <button class="btn" onclick="openEdit(${u.id})" ${editDisabled}>Sửa</button>
      <button class="btn danger" onclick="confirmDelete(${u.id})" ${delDisabled}>Xóa</button>
    </td>
  </tr>`;
}

// User data loading
async function loadUsers() {
  const tbody = document.querySelector('#tblUsers tbody');
  tbody.innerHTML = '<tr><td colspan="7" class="empty">Đang tải dữ liệu...</td></tr>';
  const url = `${API_BASE}/users?page=${currentPage}&limit=${pageSize}`;
  
  try {
    const res = await fetch(url, { headers: authHeaders() });
    const status = res.status;
    const ctype = res.headers.get('content-type') || '';
    const txtRaw = await res.text();
    const txt = (txtRaw || '').replace(/^\uFEFF/, '').trim();
    
    let data;
    try {
      data = JSON.parse(txt);
    } catch {
      const snippet = txt.length ? (txt.slice(0, 200) + (txt.length > 200 ? '…' : '')) : '(empty)';
      tbody.innerHTML = `<tr><td colspan="7" class="empty error">Lỗi: Phản hồi không hợp lệ từ server (HTTP ${status}, ${ctype}). Body: ${snippet}</td></tr>`;
      return;
    }
    
    if (handleUnauthorized(res, txt, data)) {
      tbody.innerHTML = `<tr><td colspan="7" class="empty error">Phiên đăng nhập đã hết hạn</td></tr>`;
      return;
    }
    
    if (!res.ok || !Array.isArray(data.data)) {
      tbody.innerHTML = `<tr><td colspan="7" class="empty error">${data.message || 'Không tải được danh sách người dùng'}</td></tr>`;
      return;
    }
    
    cachedPage = data.data;
    lastCount = cachedPage.length;
    
    if (!cachedPage.length) {
      tbody.innerHTML = '<tr><td colspan="7" class="empty">Không có người dùng</td></tr>';
      updatePagination();
      return;
    }
    
    tbody.innerHTML = cachedPage.map(renderRow).join('');
    updatePagination();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="7" class="empty error">Lỗi kết nối: ${err.message}</td></tr>`;
  }
}

// User CRUD operations
async function openEdit(id) {
  try {
    const res = await fetch(`${API_BASE}/users/${id}`, { headers: authHeaders() });
    const txtRaw = await res.text();
    const txt = (txtRaw || '').replace(/^\uFEFF/, '').trim();
    
    let data;
    try {
      data = JSON.parse(txt);
    } catch {
      showMessage('Lỗi tải thông tin người dùng', true);
      return;
    }
    
    if (handleUnauthorized(res, txt, data)) return;
    
    if (!res.ok || !data.success) {
      showMessage(data.message || 'Không thể tải thông tin người dùng', true);
      return;
    }
    
    const u = data.data;
    document.getElementById('dlgTitle').textContent = 'Sửa người dùng #' + id;
    document.getElementById('usrId').value = id;
    document.getElementById('usrFullName').value = u.full_name || '';
    document.getElementById('usrEmail').value = u.email || '';
    document.getElementById('usrPhone').value = u.phone || '';
    document.getElementById('usrAddress').value = u.address || '';
    document.getElementById('usrCard').value = u.card || '';
    document.getElementById('grpPassword').style.display = 'none';
    document.getElementById('usrPassword').required = false;
    document.getElementById('dlgUser').showModal();
  } catch (err) {
    showMessage('Không thể tải thông tin người dùng', true);
  }
}

async function confirmDelete(id) {
  if (!confirm('Xóa người dùng #' + id + ' ?')) return;
  
  try {
    const res = await fetch(`${API_BASE}/users/${id}`, { 
      method: 'DELETE', 
      headers: authHeaders() 
    });
    const txtRaw = await res.text();
    const txt = (txtRaw || '').replace(/^\uFEFF/, '').trim();
    
    let data;
    try {
      data = JSON.parse(txt);
    } catch {
      showMessage('Lỗi phản hồi từ server', true);
      return;
    }
    
    if (handleUnauthorized(res, txt, data)) return;
    
    if (!res.ok || !data.success) {
      showMessage(data.message || 'Xóa không thành công', true);
      return;
    }
    
    await loadUsers();
    showMessage('Đã xóa người dùng');
  } catch (err) {
    showMessage('Không thể xóa', true);
  }
}

// Event handlers setup
function setupEventHandlers() {
  // Create user button
  document.getElementById('btnCreate').addEventListener('click', () => {
    document.getElementById('dlgTitle').textContent = 'Tạo người dùng';
    document.getElementById('usrId').value = '';
    document.getElementById('usrFullName').value = '';
    document.getElementById('usrEmail').value = '';
    document.getElementById('usrPassword').value = '';
    document.getElementById('usrPhone').value = '';
    document.getElementById('usrAddress').value = '';
    document.getElementById('usrCard').value = '';
    document.getElementById('grpPassword').style.display = 'block';
    document.getElementById('usrPassword').required = true;
    document.getElementById('dlgUser').showModal();
  });

  // Form submission
  document.getElementById('frmUser').addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = document.getElementById('usrId').value.trim();
    const isEdit = !!id;
    
    if (isEdit) {
      const payload = {
        full_name: document.getElementById('usrFullName').value.trim(),
        email: document.getElementById('usrEmail').value.trim(),
        phone: document.getElementById('usrPhone').value.trim(),
        address: document.getElementById('usrAddress').value.trim(),
        card: document.getElementById('usrCard').value.trim(),
      };
      
      if (!payload.full_name || !payload.email) {
        showMessage('Vui lòng nhập đầy đủ họ tên và email', true);
        return;
      }
      
      try {
        const res = await fetch(`${API_BASE}/users/${id}`, {
          method: 'PUT',
          headers: authHeaders(),
          body: JSON.stringify(payload)
        });
        const txtRaw = await res.text();
        const txt = (txtRaw || '').replace(/^\uFEFF/, '').trim();
        
        let data;
        try {
          data = JSON.parse(txt);
        } catch {
          showMessage('Lỗi phản hồi từ server', true);
          return;
        }
        
        if (handleUnauthorized(res, txt, data)) return;
        
        if (!res.ok || !data.success) {
          showMessage(data.message || 'Cập nhật thất bại', true);
          return;
        }
        
        document.getElementById('dlgUser').close();
        await loadUsers();
        showMessage('Đã cập nhật người dùng');
      } catch (err) {
        showMessage('Không thể cập nhật', true);
      }
    } else {
      const payload = {
        full_name: document.getElementById('usrFullName').value.trim(),
        email: document.getElementById('usrEmail').value.trim(),
        password: document.getElementById('usrPassword').value,
        phone: document.getElementById('usrPhone').value.trim(),
        address: document.getElementById('usrAddress').value.trim()
      };
      
      if (!payload.full_name || !payload.email || !payload.password) {
        showMessage('Vui lòng nhập họ tên, email, mật khẩu', true);
        return;
      }
      
      try {
        console.log('Creating user with payload:', payload);
        console.log('Using API_BASE:', API_BASE);
        
        const url = `${API_BASE}/register`;
        console.log('POST URL:', url);
        
        const res = await fetch(url, {
          method: 'POST',
          headers: authHeaders(),
          body: JSON.stringify(payload)
        });
        
        console.log('Response status:', res.status);
        console.log('Response headers:', Object.fromEntries(res.headers.entries()));
        
        const txtRaw = await res.text();
        const txt = (txtRaw || '').replace(/^\uFEFF/, '').trim();
        console.log('Response text:', txt);
        
        let data;
        try {
          data = JSON.parse(txt);
          console.log('Parsed response:', data);
        } catch (parseErr) {
          console.error('JSON parse error:', parseErr);
          showMessage('Lỗi phản hồi từ server: ' + txt.substring(0, 100), true);
          return;
        }
        
        if (handleUnauthorized(res, txt, data)) return;
        
        if (!res.ok || !data.success) {
          const errorMsg = data.message || data.error || `HTTP ${res.status}: Tạo người dùng thất bại`;
          showMessage(errorMsg, true);
          return;
        }
        
        document.getElementById('dlgUser').close();
        await loadUsers();
        showMessage('Đã tạo người dùng');
      } catch (err) {
        console.error('Create user error:', err);
        showMessage('Không thể tạo người dùng: ' + err.message, true);
      }
    }
  });

  // Other event handlers
  document.getElementById('btnCancel').addEventListener('click', () => 
    document.getElementById('dlgUser').close()
  );
  
  document.getElementById('btnClear').addEventListener('click', () => {
    document.getElementById('txtSearch').value = '';
    filterLocal();
  });
  
  document.getElementById('txtSearch').addEventListener('input', filterLocal);
  
  document.getElementById('btnPrev').addEventListener('click', () => {
    if (currentPage > 1) {
      currentPage--;
      loadUsers();
    }
  });
  
  document.getElementById('btnNext').addEventListener('click', () => {
    if (lastCount >= pageSize) {
      currentPage++;
      loadUsers();
    }
  });
}

// Initialization function
async function init() {
  // Initialize admin header first
  adminHeaderInit();
  
  // Setup permissions
  document.getElementById('btnCreate').disabled = !canWrite;
  const notice = document.getElementById('noticeAuth');
  notice.textContent = 'Yêu cầu đăng nhập và quyền phù hợp để xem/sửa/xóa';
  notice.style.display = !token ? 'block' : 'none';
  
  // Setup event handlers
  setupEventHandlers();
  
  // Resolve API and load data
  await resolveApiBase();
  await loadUsers();
}

// Make functions available globally for onclick handlers
window.openEdit = openEdit;
window.confirmDelete = confirmDelete;

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
