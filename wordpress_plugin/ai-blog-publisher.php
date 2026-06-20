<?php
/**
 * Plugin Name: AI Blog Publisher
 * Description: Custom REST API endpoint for the AI Blog Agent using X-API-KEY authentication.
 * Version: 1.0.0
 * Author: Preet
 */

if (!defined('ABSPATH')) {
    exit;
}

add_action('rest_api_init', 'ai_blog_register_endpoints');

// Add x-api-key to the allowed CORS headers for Flutter Web compatibility
add_filter('rest_allowed_cors_headers', function($headers) {
    $headers[] = 'x-api-key';
    return $headers;
});

function ai_blog_register_endpoints() {
    register_rest_route('ai-blog/v1', '/publish', array(
        'methods' => 'POST',
        'callback' => 'ai_blog_publish_post',
        'permission_callback' => 'ai_blog_verify_api_key',
    ));
}

function ai_blog_verify_api_key(WP_REST_Request $request) {
    $api_key = $request->get_header('x-api-key');
    if (!$api_key) {
        return new WP_Error('missing_api_key', 'Missing X-API-KEY header', array('status' => 401));
    }
    
    // Check against wp-config.php constant
    if (defined('AI_BLOG_API_KEY') && AI_BLOG_API_KEY === $api_key) {
        return true;
    }
    
    return new WP_Error('invalid_api_key', 'Invalid API Key', array('status' => 401));
}

function ai_blog_publish_post(WP_REST_Request $request) {
    $params = $request->get_json_params();
    
    // Allow standard wp_kses tags for basic HTML formatting
    $allowed_html = wp_kses_allowed_html('post');
    
    $title = isset($params['title']) ? sanitize_text_field($params['title']) : '';
    $content = isset($params['content']) ? wp_kses($params['content'], $allowed_html) : '';
    $excerpt = isset($params['excerpt']) ? sanitize_text_field($params['excerpt']) : '';
    $status = isset($params['status']) ? sanitize_text_field($params['status']) : 'publish';
    
    if (empty($title) || empty($content)) {
        return new WP_Error('missing_data', 'Title and content are required', array('status' => 400));
    }
    
    // Fetch an admin user to be the author
    $users = get_users(array('role' => 'administrator', 'number' => 1));
    $author_id = !empty($users) ? $users[0]->ID : 1;

    $post_data = array(
        'post_title'    => $title,
        'post_content'  => $content,
        'post_excerpt'  => $excerpt,
        'post_status'   => $status,
        'post_author'   => $author_id,
        'post_type'     => 'post'
    );
    
    // Create the post
    $post_id = wp_insert_post($post_data, true);
    
    if (is_wp_error($post_id)) {
        return $post_id;
    }
    
    // Handle tags if passed as array of strings
    if (isset($params['tags']) && is_array($params['tags'])) {
        wp_set_post_tags($post_id, $params['tags'], false);
    }
    
    // Handle categories if passed as array of strings
    if (isset($params['categories']) && is_array($params['categories'])) {
        $cat_ids = array();
        foreach ($params['categories'] as $cat_name) {
            $term = term_exists($cat_name, 'category');
            if (!$term) {
                $term = wp_insert_term($cat_name, 'category');
            }
            if (!is_wp_error($term) && isset($term['term_id'])) {
                $cat_ids[] = (int) $term['term_id'];
            }
        }
        if (!empty($cat_ids)) {
            wp_set_post_categories($post_id, $cat_ids, false);
        }
    }
    
    // Handle Yoast or standard Meta
    if (isset($params['meta']) && is_array($params['meta'])) {
        foreach ($params['meta'] as $key => $value) {
            update_post_meta($post_id, sanitize_key($key), sanitize_text_field($value));
        }
    }
    
    // Set Featured Image
    if (isset($params['featured_media']) && is_numeric($params['featured_media'])) {
        set_post_thumbnail($post_id, intval($params['featured_media']));
    }
    
    return rest_ensure_response(array(
        'success' => true,
        'postId' => $post_id
    ));
}

// ── Media Upload Endpoint ─────────────────────────────────────────────────────

add_action('rest_api_init', 'ai_blog_register_media_endpoint');

function ai_blog_register_media_endpoint() {
    register_rest_route('ai-blog/v1', '/upload-media', array(
        'methods' => 'POST',
        'callback' => 'ai_blog_upload_media',
        'permission_callback' => 'ai_blog_verify_api_key',
    ));
}

function ai_blog_upload_media(WP_REST_Request $request) {
    require_once(ABSPATH . 'wp-admin/includes/image.php');
    require_once(ABSPATH . 'wp-admin/includes/file.php');
    require_once(ABSPATH . 'wp-admin/includes/media.php');

    $file_params = $request->get_file_params();

    if (empty($file_params['file'])) {
        return new WP_Error('missing_file', 'No file uploaded', array('status' => 400));
    }

    $file = $file_params['file'];
    
    $attachment_id = media_handle_sideload($file, 0);

    if (is_wp_error($attachment_id)) {
        return new WP_Error('upload_error', $attachment_id->get_error_message(), array('status' => 500));
    }

    $url = wp_get_attachment_url($attachment_id);

    return rest_ensure_response(array(
        'success' => true,
        'mediaId' => $attachment_id,
        'url' => $url
    ));
}

