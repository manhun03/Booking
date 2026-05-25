package com.doan.hotelparking.repository;

import com.doan.hotelparking.domain.entity.Hotel;
import com.doan.hotelparking.domain.enums.HotelStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface HotelRepository extends JpaRepository<Hotel, Integer> {
    @Override
    @EntityGraph(attributePaths = {"ward", "ward.province"})
    Page<Hotel> findAll(Pageable pageable);

    @EntityGraph(attributePaths = {"ward", "ward.province"})
    @Query("select h from Hotel h where h.isDeleted = false")
    Page<Hotel> findVisible(Pageable pageable);

    @EntityGraph(attributePaths = {"ward", "ward.province"})
    @Query("select h from Hotel h where h.id = :id and h.isDeleted = false")
    Optional<Hotel> findVisibleById(@Param("id") Integer id);

    List<Hotel> findByOwnerId(Integer ownerId);

    @EntityGraph(attributePaths = {"ward", "ward.province"})
    @Query("select h from Hotel h where h.owner.id = :ownerId and h.isDeleted = false")
    List<Hotel> findVisibleByOwnerId(@Param("ownerId") Integer ownerId);

    @EntityGraph(attributePaths = {"ward", "ward.province"})
    List<Hotel> findByWardProvinceNameContainingIgnoreCase(String province);

    @EntityGraph(attributePaths = {"ward", "ward.province"})
    @Query("""
            select h from Hotel h
            join h.ward w
            join w.province p
            where h.isDeleted = false
              and lower(p.name) like lower(concat('%', :province, '%'))
            """)
    List<Hotel> findVisibleByProvinceName(@Param("province") String province);

    @EntityGraph(attributePaths = {"ward", "ward.province"})
    List<Hotel> findByNameContainingIgnoreCase(String name);

    @EntityGraph(attributePaths = {"ward", "ward.province"})
    @Query("""
            select h from Hotel h
            where h.isDeleted = false
              and lower(h.name) like lower(concat('%', :name, '%'))
            """)
    List<Hotel> findVisibleByName(@Param("name") String name);

    @EntityGraph(attributePaths = {"ward", "ward.province", "rooms", "rooms.bookings", "rooms.reviews", "hotelImages"})
    @Query("select h from Hotel h where h.id = :id")
    Optional<Hotel> findDetailedById(Integer id);

    @EntityGraph(attributePaths = {"ward", "ward.province", "rooms", "rooms.bookings", "rooms.reviews", "hotelImages"})
    @Query("select h from Hotel h where h.id = :id and h.isDeleted = false")
    Optional<Hotel> findVisibleDetailedById(@Param("id") Integer id);

    @EntityGraph(attributePaths = {"ward", "ward.province", "rooms", "rooms.bookings", "rooms.reviews", "hotelImages"})
    @Query("""
            select distinct h from Hotel h
            join h.ward w
            join w.province p
            where h.isDeleted = false
              and h.status = :status
              and (:province is null or lower(p.name) like lower(concat('%', :province, '%')))
              and (:ward is null or lower(w.name) like lower(concat('%', :ward, '%')))
            """)
    List<Hotel> findActiveDetailed(@Param("status") HotelStatus status,
                                   @Param("province") String province,
                                   @Param("ward") String ward);
}
