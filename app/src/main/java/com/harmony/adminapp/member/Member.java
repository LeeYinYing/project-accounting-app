package com.harmony.adminapp.member;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.util.Arrays;
import java.util.List;

import jakarta.persistence.Column;

@Entity
@Table(name="members", schema="harmony_accounting")
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private long id;
    private String name;
    private boolean performer;
    private String phone;
    private String email;
    private String street;
    private String city;
    private String province;
    @Column(name="postal_code")
    private String postalCode;
    private boolean active;

    protected Member() {

	}

	public Member(String name, boolean performer, String phone, String email,
                  String street, String city, String province, String postalCode, 
                  boolean active) {
		this.name = name;
		this.performer = performer;
		this.phone = phone;
        this.email = email;
        this.street = street;
        this.city = city;
        this.province = province;
        this.postalCode = postalCode;
        this.active = active;
	}

    public long getId() {
        return id;
    }
    public String getName() {
        return name;
    }
    public boolean isPerformer() {
        return performer;
    }
    public String getEmail() {
        return email;
    }
    public String getPhone() {
        return phone;
    }
    public String getAddress() {
        List<String> list = Arrays.asList(street, city, province, postalCode);
        return String.join(", ", list);
    }
    public boolean isActive(){
        return active;
    }
}
