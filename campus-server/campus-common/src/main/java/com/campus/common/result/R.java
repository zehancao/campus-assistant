package com.campus.common.result;

/**
 * 统一响应封装
 */
public class R<T> {

    private int code;
    private String message;
    private T data;

    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }

    public static <T> R<T> ok(T data) {
        R<T> r = new R<>();
        r.code = 200;
        r.message = "success";
        r.data = data;
        return r;
    }

    public static <T> R<T> ok() {
        return ok(null);
    }

    public static <T> R<T> fail(int code, String message) {
        R<T> r = new R<>();
        r.code = code;
        r.message = message;
        r.data = null;
        return r;
    }

    public static <T> R<T> fail(String message) {
        return fail(500, message);
    }

    public static <T> R<T> unauthorized(String message) {
        return fail(401, message);
    }
}
