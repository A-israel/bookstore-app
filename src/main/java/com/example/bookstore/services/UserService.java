package com.example.bookstore.services;

import com.example.bookstore.config.PasswordHash;
import com.example.bookstore.dto.request.LoginReq;
import com.example.bookstore.dto.request.UserReq;
import com.example.bookstore.repositories.UserRepository;
import com.example.bookstore.tables.Users;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private UserRepository rep;
    private UserReq ureq;
    private PasswordHash hash;
    private Users u;
    private UserService(UserRepository rep,PasswordHash hash){
        this.rep = rep;
        this.hash = hash;
    }

    public boolean register(UserReq ureq){
        boolean truthy = false;
        Users u = new Users();
        u.setFirstname(ureq.getFirstname());
        u.setLastname(ureq.getLastname());
        u.setEmail(ureq.getEmail());
        u.setPassword(hash.getHashed(u.getPassword()));
        u.setShipping_address(ureq.getShipping_address());
        u.setRole("USER");
        Users indatabase = rep.save(u);

        if(indatabase != null){
            truthy = true;
            return truthy;
        }
        return truthy;
    }

    public boolean userLogin(LoginReq lreq,HttpServletRequest request){
        boolean truthy = false;
        HttpSession session = request.getSession();
        Users old_user = rep.findUsersByEmail(lreq.getEmail());
        if(old_user != null){
            truthy = true;
            session.setAttribute("key",old_user.getEmail());
        }
        return truthy;

    }
    public boolean changeUser(UserReq ureq, HttpServletRequest request){
        boolean truthy =false;
        HttpSession session = request.getSession();
        Users old = rep.findUsersByEmail(ureq.getEmail());
        old.setFirstname(ureq.getFirstname());
        old.setLastname(ureq.getLastname());
        old.setEmail(ureq.getEmail());
        old.setShipping_address(ureq.getShipping_address());
        old.setPassword(ureq.getPassword());
        Users updated = rep.save(old);
        if(updated !=null){
            truthy= true;
            session.setAttribute("key",updated.getEmail());
        }
        return truthy;
    }
    public  boolean deleteuser(HttpServletRequest request){
        boolean truthy = false;
        HttpSession session = request.getSession();
        String email  = (String)session.getAttribute("key");
        Users what_delete =rep.findUsersByEmail(email);
        rep.delete(what_delete);
        truthy = true;
        return truthy;

    }
}
