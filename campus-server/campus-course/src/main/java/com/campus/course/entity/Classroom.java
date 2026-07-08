package com.campus.course.entity;

import com.baomidou.mybatisplus.annotation.*;

@TableName("classrooms")
public class Classroom {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String building;
    private String roomNo;
    private Integer capacity;
    private Integer hasProjector;
    private Integer hasAc;
    private String type;
    private String status;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getBuilding() { return building; }
    public void setBuilding(String building) { this.building = building; }
    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }
    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }
    public Integer getHasProjector() { return hasProjector; }
    public void setHasProjector(Integer hasProjector) { this.hasProjector = hasProjector; }
    public Integer getHasAc() { return hasAc; }
    public void setHasAc(Integer hasAc) { this.hasAc = hasAc; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
