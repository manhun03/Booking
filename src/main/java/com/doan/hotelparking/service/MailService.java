package com.doan.hotelparking.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class MailService {
    private final JavaMailSender mailSender;
    private final String mailHost;
    private final String username;
    private final String password;
    private final String from;

    public MailService(JavaMailSender mailSender,
                       @Value("${spring.mail.host:}") String mailHost,
                       @Value("${spring.mail.username:}") String username,
                       @Value("${spring.mail.password:}") String password) {
        this.mailSender = mailSender;
        this.mailHost = mailHost;
        this.username = username;
        this.password = password;
        this.from = username == null || username.isBlank() ? "no-reply@localhost" : username;
    }

    public void send(String to, String subject, String body) {
        if (mailHost == null || mailHost.isBlank()
                || username == null || username.isBlank()
                || password == null || password.isBlank()) {
            throw new IllegalArgumentException(
                    "Email service is not configured. Set MAIL_HOST, MAIL_USERNAME and MAIL_PASSWORD.");
        }
        var message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);
        mailSender.send(message);
    }
}
