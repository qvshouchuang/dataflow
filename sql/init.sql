CREATE TABLE IF NOT EXISTS ods_user_behavior (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    item_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    behavior_type VARCHAR(10) NOT NULL,
    event_time DATETIME NOT NULL,
    tenant_id VARCHAR(32) DEFAULT 'shop001',
    INDEX idx_user (user_id),
    INDEX idx_event_time (event_time),
    INDEX idx_behavior (behavior_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;