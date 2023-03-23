-- Şirket yetkilisi tur tanımlaması yaparken, sistemde kayıtlı hizmet verdiği yerlerden en az 1, en fazla 3 tanesini seçebilir.

CREATE TRIGGER BolgeSecimiSınırlamasi
ON Bolge
INSTEAD OF INSERT
AS
BEGIN 
    DECLARE @turid AS INT
	SELECT @turid= TurID
	FROM inserted

	DECLARE @sayac AS INT
	SELECT @sayac = COUNT (TurID) 
	FROM Bolge
	WHERE @turid= TurID

	IF @sayac <=3
	BEGIN
	
	 INSERT INTO Bolge(TurID)
	  SELECT TurID
	   FROM inserted
	   END
	   ELSE
	   BEGIN
	PRINT 'Fazla sayıda bölge girişi yapılmıştır. Tur tanımlaması yapılamaz.'
	END
END

 -- Müşterilerin en çok tercih ettiği favori kanalı hangisidir?
 SELECT TOP 1 d.KanalID,d.KanalAd
 FROM TurSatis ts
 JOIN DigerKanal d ON ts.KanalID=d.KanalID
 JOIN TurSatisDetay tsd ON tsd.SatisID= ts.SatisID
 JOIN Musteri m ON tsd.MusteriSatisID = m.MusteriID
 GROUP BY d.KanalAd,d.KanalID
 ORDER BY COUNT (d.KanalID) DESC

 -- Turist kapasitesini en az dolduran tur hangisidir?

 SELECT TOP 1 t.TurNo,TurAd,(t.Kapasite-count(MusteriSatisID)) AS 'Boş Kalan Yer Sayısı'
 FROM Tur t 
 JOIN TurSatisDetay tsd ON tsd.TurID=t.TurNo
 JOIN Musteri m ON m.MusteriID=tsd.MusteriSatisID
 JOIN TurSatis ts ON ts.SatisID=tsd.SatisID
 GROUP BY t.TurNo,t.Kapasite,TurAd
 ORDER BY [Boş Kalan Yer Sayısı] DESC

-- Adım Adım Beyoğlu turuna katılan turistler hangi ülkelerden gelmişlerdir?
 SELECT DISTINCT Ulke,MusteriAd+ ' ' + Soyad AS Musteri
 FROM Tur t
 JOIN TurSatisDetay tsd ON t.TurNo=tsd.TurID
 JOIN Musteri m ON m.MusteriID=tsd.MusteriSatisID
 WHERE t.TurAd = 'Adim Adim Beyoglu'

 -- Beş kez ya da daha fazla kez satın alınan turlar hangileridir?
 SELECT t.TurNo,t.TurAd
 FROM Tur t
 JOIN TurSatisDetay tsd ON t.TurNo = tsd.TurID
 JOIN TurSatis ts ON ts.SatisID=tsd.SatisID
 GROUP BY t.TurAd,t.TurNo
 HAVING COUNT (ts.SatisID) >=5

 --Tur tarihinden en az 1 hafta önce, tur satın alan müşterilerimize özel %5 erken rezervasyon indirimi yapılacaktır.Fakat her müşteri sadece tek 
 --bir indirim hakkından yararlanabilir. (60 yaş üstü kişileri bu indirimin dışında tuttum.)

SELECT DISTINCT
CASE
WHEN DATEDIFF(DAY,fu.FaturaKesimTarih,TurTarih)>=7 THEN [Fatura Ücreti]*0.95
ELSE [Fatura Ücreti]
END
AS
ErkenRezervasyonIndirimi,
[Fatura Ücreti],
MusteriAd+ ' ' + Soyad AS Musteri

FROM vw_FaturaUcreti fu
JOIN vw_altmisyastankucukmusteri ak ON ak.MusteriID=fu.MusteriID
JOIN TurSatis ts ON ts.FaturaKesimTarih=fu.FaturaKesimTarih
JOIN TurSatisDetay tsd ON tsd.SatisID=ts.SatisID
JOIN Tur t ON t.TurNo= tsd.TurID

--Rehberler arasında en çok bilinen dil hangisidir?
SELECT TOP 1 d.DilID,d.DilAd
FROM Calisan c
JOIN CalisanDil cd ON cd.CalisanID= c.CalisanID
JOIN Dil d ON d.DilID=cd.DilID








