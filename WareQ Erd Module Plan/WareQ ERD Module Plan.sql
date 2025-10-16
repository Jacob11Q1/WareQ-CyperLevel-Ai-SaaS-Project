-- ================
-- Multi-Tenancy & Users
-- ================
CREATE TABLE organizations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    domain VARCHAR(150),
    industry VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    global_role ENUM('super_admin','user') DEFAULT 'user',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE organization_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    user_id INT,
    role ENUM('owner','manager','staff','viewer'),
    invited_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (org_id) REFERENCES organizations(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ================
-- SaaS Subscriptions
-- ================
CREATE TABLE subscription_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    features JSON,
    billing_cycle ENUM('monthly','yearly'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    plan_id INT,
    status ENUM('active','paused','canceled'),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (org_id) REFERENCES organizations(id),
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id)
);

-- ================
-- Warehouses & Inventory
-- ================
CREATE TABLE warehouses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    name VARCHAR(150),
    location VARCHAR(255),
    capacity INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (org_id) REFERENCES organizations(id)
);

CREATE TABLE warehouse_zones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT,
    name VARCHAR(100),
    type ENUM('storage','picking','packing','cold_storage'),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

CREATE TABLE bins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    zone_id INT,
    code VARCHAR(50),
    capacity INT,
    status ENUM('available','full','reserved'),
    FOREIGN KEY (zone_id) REFERENCES warehouse_zones(id)
);

CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT,
    sku VARCHAR(100) UNIQUE,
    name VARCHAR(150),
    description TEXT,
    quantity INT,
    reorder_level INT,
    unit_price DECIMAL(10,2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

CREATE TABLE inventory_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    user_id INT,
    change_type ENUM('add','remove','adjust'),
    quantity_change INT,
    note VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ================
-- Procurement & Suppliers
-- ================
CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    name VARCHAR(150),
    contact_info VARCHAR(255),
    address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (org_id) REFERENCES organizations(id)
);

CREATE TABLE purchase_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    warehouse_id INT,
    status ENUM('draft','confirmed','received','canceled'),
    total_amount DECIMAL(10,2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    received_at DATETIME,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

CREATE TABLE purchase_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT,
    item_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (item_id) REFERENCES items(id)
);

-- ================
-- Customers & Orders
-- ================
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    name VARCHAR(150),
    email VARCHAR(150),
    phone VARCHAR(50),
    address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (org_id) REFERENCES organizations(id)
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    org_id INT,
    warehouse_id INT,
    status ENUM('pending','processing','shipped','delivered','canceled'),
    order_type ENUM('online','wholesale'),
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (org_id) REFERENCES organizations(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (item_id) REFERENCES items(id)
);

-- ================
-- Logistics & Shipping
-- ================
CREATE TABLE carriers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150),
    contact_info VARCHAR(255),
    tracking_url VARCHAR(255)
);

CREATE TABLE shipments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    carrier_id INT,
    tracking_no VARCHAR(100),
    status ENUM('pending','in_transit','delivered','failed'),
    shipped_at DATETIME,
    delivered_at DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (carrier_id) REFERENCES carriers(id)
);

-- ================
-- Finance
-- ================
CREATE TABLE invoices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    total DECIMAL(10,2),
    status ENUM('unpaid','paid','overdue','canceled'),
    issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT,
    method ENUM('card','paypal','wire'),
    amount DECIMAL(10,2),
    status ENUM('pending','completed','failed'),
    paid_at DATETIME,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id)
);

CREATE TABLE refunds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT,
    amount DECIMAL(10,2),
    reason VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES payments(id)
);

-- ================
-- Workforce & Tasks
-- ================
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    name VARCHAR(150),
    position VARCHAR(100),
    contact VARCHAR(100),
    hired_at DATE,
    FOREIGN KEY (org_id) REFERENCES organizations(id)
);

CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assigned_user INT,
    type ENUM('pick','pack','load','audit'),
    status ENUM('pending','in_progress','done'),
    due_date DATETIME,
    FOREIGN KEY (assigned_user) REFERENCES users(id)
);

-- ================
-- Quality Control
-- ================
CREATE TABLE qc_inspections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    batch_no VARCHAR(100),
    inspector_id INT,
    status ENUM('passed','failed'),
    notes TEXT,
    inspected_at DATETIME,
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (inspector_id) REFERENCES users(id)
);

CREATE TABLE returns (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    item_id INT,
    reason VARCHAR(255),
    status ENUM('requested','approved','rejected','completed'),
    returned_at DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (item_id) REFERENCES items(id)
);

-- ================
-- Security & Logs
-- ================
CREATE TABLE api_keys (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    api_key VARCHAR(255),
    permissions JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    revoked_at DATETIME,
    FOREIGN KEY (org_id) REFERENCES organizations(id)
);

CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100),
    entity_type VARCHAR(100),
    entity_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ================
-- Communication & Support
-- ================
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    message TEXT,
    type ENUM('email','sms','in_app'),
    read_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE support_tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    user_id INT,
    subject VARCHAR(255),
    description TEXT,
    status ENUM('open','in_progress','closed'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    closed_at DATETIME,
    FOREIGN KEY (org_id) REFERENCES organizations(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ================
-- Analytics & Config
-- ================
CREATE TABLE reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT,
    type ENUM('sales','inventory','performance'),
    generated_at DATETIME,
    file_url VARCHAR(255),
    FOREIGN KEY (org_id) REFERENCES organizations(id)
);

CREATE TABLE dashboard_configs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    preferences JSON,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
