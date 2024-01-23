package com.harmony.adminapp.member;

import java.util.List;

import org.springframework.data.repository.CrudRepository;

public interface MemberRepository extends CrudRepository<Member, Long> {
    List<Member> findByActive(boolean active);
    List<Member> findByPerformer(boolean performer);
    List<Member> findByActiveAndPerformer(boolean active, boolean performer);
}

