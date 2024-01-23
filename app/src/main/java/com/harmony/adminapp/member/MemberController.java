package com.harmony.adminapp.member;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MemberController {
    @Autowired
	MemberRepository memberRepository;

    @GetMapping("/members")
    public Iterable<Member> findAllMembers() {
        return memberRepository.findAll();
    }

    @GetMapping("/members/active")
    public Iterable<Member> findAllActiveMembers() {
        return memberRepository.findByActive(true);
    }

    @GetMapping("/members/active/performers") 
    public Iterable<Member> findAllActivePerformers() {
        return memberRepository.findByActiveAndPerformer(true, true);
    }

    @GetMapping("/members/active/volunteers") 
    public Iterable<Member> findAllActiveVolunteers() {
        return memberRepository.findByActiveAndPerformer(true, false);
    }

    @GetMapping("/member/healthcheck")
	public String healthcheck() {
		return "Members Endpoint is Running!";
	}

}
