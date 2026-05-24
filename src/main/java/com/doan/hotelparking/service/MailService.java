package com.doan.hotelparking.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class MailService {
    private final JavaMailSender mailSender;
    private final String mailHost;
    private final String from;

    public MailService(JavaMailSender mailSender,
                       @Value("${spring.mail.host:}") String mailHost,
                       @Value("${spring.mail.username:no-reply@localhost}") String from) {
        this.mailSender = mailSender;
        this.mailHost = mailHost;
        this.from = from;
    }

    public void send(String to, String subject, String body) {
        if (mailHost == null || mailHost.isBlank()) {
            return;
        }
        var message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);
        mailSender.send(message);
    }
}
