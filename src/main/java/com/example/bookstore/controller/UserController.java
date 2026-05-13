package com.example.bookstore.controller;

import com.example.bookstore.dto.request.LoginReq;
import com.example.bookstore.dto.request.UserReq;
import com.example.bookstore.services.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/") //http:/localhost:8080/api/
@CrossOrigin("*")
public class UserController {
    private UserService userservice;
    public  UserController(UserService uservice){
        this.userservice = uservice;

    }
    //http:/localhost:8080/api/register
    @PostMapping("/register")
    public boolean registerMe(@RequestBody UserReq ureq){
        return userservice.register(ureq);
    }
    @GetMapping("/login")
    public boolean log(@RequestBody LoginReq lreq,HttpServletRequest request){
        return userservice.userLogin(lreq,request);
    }
    @PutMapping("/update")
    public boolean change(@RequestBody UserReq ureq,HttpServletRequest request){
        return userservice.changeUser(ureq,request);
    }
    public boolean delete(@RequestBody HttpServletRequest request){
        return userservice.deleteuser(request);
    }


}