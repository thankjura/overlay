diff -ru cpp-ethereum/libstratum/CMakeLists.txt ethminer.git/libstratum/CMakeLists.txt
--- cpp-ethereum/libstratum/CMakeLists.txt	2017-06-23 21:38:46.780605179 +0300
+++ ethminer.git/libstratum/CMakeLists.txt	2017-06-23 21:27:24.156627313 +0300
@@ -1,15 +1,8 @@
-set(EXECUTABLE ethstratum)
-set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DSTATICLIB -fpermissive")
-aux_source_directory(. SRC_LIST)
+set(SOURCES
+    EthStratumClient.h EthStratumClient.cpp
+    EthStratumClientV2.h EthStratumClientV2.cpp
+)
 
-include_directories(..)
-include_directories(${Boost_INCLUDE_DIRS})
-include_directories(${JSONCPP_INCLUDE_DIRS})
-
-file(GLOB HEADERS "*.h")
-
-add_library(${EXECUTABLE} ${SRC_LIST} ${HEADERS})
-target_link_libraries(${EXECUTABLE} ${Boost_SYSTEM_LIBRARY} ${Boost_THREAD_LIBRARY} ${Boost_REGEX_LIBRARY}) 
-
-install( TARGETS ${EXECUTABLE} RUNTIME DESTINATION bin ARCHIVE DESTINATION lib LIBRARY DESTINATION lib )
-install( FILES ${HEADERS} DESTINATION include/${EXECUTABLE} )
+add_library(ethstratum ${SOURCES})
+target_link_libraries(ethstratum PUBLIC Boost::system jsoncpp_lib_static)
+target_include_directories(ethstratum PRIVATE ..)
diff -ru cpp-ethereum/libstratum/EthStratumClient.cpp ethminer.git/libstratum/EthStratumClient.cpp
--- cpp-ethereum/libstratum/EthStratumClient.cpp	2017-06-23 21:38:46.780605179 +0300
+++ ethminer.git/libstratum/EthStratumClient.cpp	2017-06-23 21:27:24.156627313 +0300
@@ -27,7 +27,7 @@
 }
 
 
-EthStratumClient::EthStratumClient(GenericFarm<EthashProofOfWork> * f, MinerType m, string const & host, string const & port, string const & user, string const & pass, int const & retries, int const & worktimeout, int const & protocol, string const & email)
+EthStratumClient::EthStratumClient(Farm* f, MinerType m, string const & host, string const & port, string const & user, string const & pass, int const & retries, int const & worktimeout, int const & protocol, string const & email)
 	: m_socket(m_io_service)
 {
 	m_minerType = m;
@@ -54,7 +54,8 @@
 
 EthStratumClient::~EthStratumClient()
 {
-
+	m_io_service.stop();
+	m_serviceThread.join();
 }
 
 void EthStratumClient::setFailover(string const & host, string const & port)
@@ -72,18 +73,25 @@
 
 void EthStratumClient::connect()
 {
-	
 	tcp::resolver r(m_io_service);
 	tcp::resolver::query q(p_active->host, p_active->port);
 	
 	r.async_resolve(q, boost::bind(&EthStratumClient::resolve_handler,
-																	this, boost::asio::placeholders::error,
-																	boost::asio::placeholders::iterator));
-	
+					this, boost::asio::placeholders::error,
+					boost::asio::placeholders::iterator));
+
 	cnote << "Connecting to stratum server " << p_active->host + ":" + p_active->port;
 
-	boost::thread t(boost::bind(&boost::asio::io_service::run, &m_io_service));
-	
+	if (m_serviceThread.joinable())
+	{
+		// If the service thread have been created try to reset the service.
+		m_io_service.reset();
+	}
+	else
+	{
+		// Otherwise, if the first time here, create new thread.
+		m_serviceThread = std::thread{boost::bind(&boost::asio::io_service::run, &m_io_service)};
+	}
 }
 
 #define BOOST_ASIO_ENABLE_CANCELIO 
@@ -122,7 +130,7 @@
 	}
 	
 	cnote << "Reconnecting in 3 seconds...";
-	boost::asio::deadline_timer     timer(m_io_service, boost::posix_time::seconds(3));
+	boost::asio::deadline_timer timer(m_io_service, boost::posix_time::seconds(3));
 	timer.wait();
 
 	connect();
@@ -147,8 +155,8 @@
 	if (!ec)
 	{
 		async_connect(m_socket, i, boost::bind(&EthStratumClient::connect_handler,
-																					this, boost::asio::placeholders::error,
-																					boost::asio::placeholders::iterator));
+						this, boost::asio::placeholders::error,
+						boost::asio::placeholders::iterator));
 	}
 	else
 	{
@@ -267,7 +275,6 @@
 			if (reader.parse(response.c_str(), responseObject))
 			{
 				processReponse(responseObject);
-				m_response = response;
 			}
 			else 
 			{
@@ -301,7 +308,7 @@
 
 void EthStratumClient::processReponse(Json::Value& responseObject)
 {
-	Json::Value error = responseObject.get("error", new Json::Value);
+	Json::Value error = responseObject.get("error", {});
 	if (error.isArray())
 	{
 		string msg = error.get(1, "Unknown error").asString();
@@ -497,11 +504,11 @@
 	}
 }
 
-bool EthStratumClient::submit(EthashProofOfWork::Solution solution) {
+bool EthStratumClient::submit(Solution solution) {
 	x_current.lock();
-	EthashProofOfWork::WorkPackage tempWork(m_current);
+	WorkPackage tempWork(m_current);
 	string temp_job = m_job;
-	EthashProofOfWork::WorkPackage tempPreviousWork(m_previous);
+	WorkPackage tempPreviousWork(m_previous);
 	string temp_previous_job = m_previousJob;
 	x_current.unlock();
 
diff -ru cpp-ethereum/libstratum/EthStratumClient.h ethminer.git/libstratum/EthStratumClient.h
--- cpp-ethereum/libstratum/EthStratumClient.h	2017-06-23 20:57:08.902686172 +0300
+++ ethminer.git/libstratum/EthStratumClient.h	2017-06-23 21:27:24.156627313 +0300
@@ -21,7 +21,7 @@
 class EthStratumClient
 {
 public:
-	EthStratumClient(GenericFarm<EthashProofOfWork> * f, MinerType m, string const & host, string const & port, string const & user, string const & pass, int const & retries, int const & worktimeout, int const & protocol, string const & email);
+	EthStratumClient(Farm* f, MinerType m, string const & host, string const & port, string const & user, string const & pass, int const & retries, int const & worktimeout, int const & protocol, string const & email);
 	~EthStratumClient();
 
 	void setFailover(string const & host, string const & port);
@@ -32,7 +32,7 @@
 	h256 currentHeaderHash() { return m_current.headerHash; }
 	bool current() { return m_current; }
 	unsigned waitState() { return m_waitState; }
-	bool submit(EthashProofOfWork::Solution solution);
+	bool submit(Solution solution);
 	void reconnect();
 private:
 	void connect();
@@ -65,21 +65,20 @@
 
 	int m_waitState = MINER_WAIT_STATE_WORK;
 
-	boost::mutex x_pending;
+	std::mutex x_pending;
 	int m_pending;
-	string m_response;
 
-	GenericFarm<EthashProofOfWork> * p_farm;
-	boost::mutex x_current;
-	EthashProofOfWork::WorkPackage m_current;
-	EthashProofOfWork::WorkPackage m_previous;
+	Farm* p_farm;
+	std::mutex x_current;
+	WorkPackage m_current;
+	WorkPackage m_previous;
 
 	bool m_stale = false;
 
 	string m_job;
 	string m_previousJob;
-	EthashAux::FullType m_dag;
 
+	std::thread m_serviceThread;  ///< The IO service thread.
 	boost::asio::io_service m_io_service;
 	tcp::socket m_socket;
 
diff -ru cpp-ethereum/libstratum/EthStratumClientV2.cpp ethminer.git/libstratum/EthStratumClientV2.cpp
--- cpp-ethereum/libstratum/EthStratumClientV2.cpp	2017-06-23 21:38:46.780605179 +0300
+++ ethminer.git/libstratum/EthStratumClientV2.cpp	2017-06-23 21:27:24.156627313 +0300
@@ -1,6 +1,5 @@
 
 #include "EthStratumClientV2.h"
-#include <json/json.h>
 #include <libdevcore/Log.h>
 #include <libethash/endian.h>
 using boost::asio::ip::tcp;
@@ -28,10 +27,9 @@
 }
 
 
-EthStratumClientV2::EthStratumClientV2(GenericFarm<EthashProofOfWork> * f, MinerType m, string const & host, string const & port, string const & user, string const & pass, int const & retries, int const & worktimeout, int const & protocol, string const & email)
+EthStratumClientV2::EthStratumClientV2(Farm* f, MinerType m, string const & host, string const & port, string const & user, string const & pass, int const & retries, int const & worktimeout, int const & protocol, string const & email)
 	: Worker("stratum"), 
-	  m_socket(m_io_service),
-	  m_worktimer(m_io_service, boost::posix_time::milliseconds(0))
+	  m_socket(m_io_service)
 {
 	m_minerType = m;
 	m_primary.host = host;
@@ -50,6 +48,7 @@
 	m_email = email;
 
 	p_farm = f;
+	p_worktimer = nullptr;
 	startWorking();
 }
 
@@ -90,7 +89,6 @@
 
 			if (!response.empty() && response.front() == '{' && response.back() == '}')
 			{
-				cdebug << "received: " << response;
 				Json::Value responseObject;
 				Json::Reader reader;
 				if (reader.parse(response.c_str(), responseObject))
@@ -140,9 +138,6 @@
 	{
 		cnote << "Connected!";
 		m_connected = true;
-		boost::asio::socket_base::keep_alive option_ka(true);
-		m_socket.set_option(option_ka);
-
 		if (!p_farm->isMining())
 		{
 			cnote << "Starting farm";
@@ -195,7 +190,10 @@
 
 void EthStratumClientV2::reconnect()
 {
-	m_worktimer.cancel();
+	if (p_worktimer) {
+		p_worktimer->cancel();
+		p_worktimer = nullptr;
+	}
 
 	//m_io_service.reset();
 	//m_socket.close(); // leads to crashes on Linux
@@ -252,24 +250,17 @@
 	m_extraNonce = h64(enonce);
 }
 
-void EthStratumClientV2::jobReport()
-{
-	cnote << "New job" << m_job << 
-			 "target " << m_current.boundary.hex().substr(4, 8) << 
-			 "header " << m_current.headerHash.hex().substr(0,8);
-}
-
 void EthStratumClientV2::processReponse(Json::Value& responseObject)
 {
-	Json::Value json_err = responseObject.get("error", Json::Value::null);
-	if (!json_err.isNull())
+	Json::Value error = responseObject.get("error", new Json::Value);
+	if (error.isArray())
 	{
-		cwarn << "unknown stratum error";
+		string msg = error.get(1, "Unknown error").asString();
+		cnote << msg;
 	}
 	std::ostream os(&m_requestBuffer);
 	Json::Value params;
 	int id = responseObject.get("id", Json::Value::null).asInt();
-	long responseTime = 0;
 	switch (id)
 	{
 		case 1:
@@ -313,17 +304,13 @@
 		cnote << "Authorized worker " << p_active->user;
 		break;
 	case 4:
-	case 6:
-		// id 6 == stale submit
-		responseTime = m_worktimeout -  m_worktimer.expires_from_now().total_milliseconds();
-		//m_worktimer.cancel();
 		if (responseObject.get("result", false).asBool()) {
-			cnote << "B-) Submitted and accepted in" << responseTime << "ms.";
-			p_farm->acceptedSolution(id==6);
+			cnote << "B-) Submitted and accepted.";
+			p_farm->acceptedSolution(m_stale);
 		}
 		else {
-			cwarn << ":-( Rejected in" << responseTime << "ms.";
-			p_farm->rejectedSolution(id==6);
+			cwarn << ":-( Not accepted.";
+			p_farm->rejectedSolution(m_stale);
 		}
 		break;
 	default:
@@ -357,9 +344,15 @@
 
 					if (sHeaderHash != "" && sSeedHash != "")
 					{
+						cnote << "Received new job #" + job;
+
 						h256 seedHash = h256(sSeedHash);
 
-						m_previous  = m_current;
+						m_previous.headerHash = m_current.headerHash;
+						m_previous.seedHash = m_current.seedHash;
+						m_previous.boundary = m_current.boundary;
+						m_previous.startNonce = m_current.startNonce;
+						m_previous.exSizeBits = m_previous.exSizeBits;
 						m_previousJob = m_job;
 
 						m_current.headerHash = h256(sHeaderHash);
@@ -371,7 +364,6 @@
 						m_job = job;
 
 						p_farm->setWork(m_current);
-						jobReport();			// display new job info
 					}
 				}
 				else
@@ -388,6 +380,8 @@
 
 					if (sHeaderHash != "" && sSeedHash != "" && sShareTarget != "")
 					{
+						cnote << "Received new job #" + job.substr(0, 8);
+
 						h256 seedHash = h256(sSeedHash);
 						h256 headerHash = h256(sHeaderHash);
 
@@ -397,7 +391,9 @@
 							//if (p_worktimer)
 							//	p_worktimer->cancel();
 
-							m_previous  = m_current;
+							m_previous.headerHash = m_current.headerHash;
+							m_previous.seedHash = m_current.seedHash;
+							m_previous.boundary = m_current.boundary;
 							m_previousJob = m_job;
 
 							m_current.headerHash = h256(sHeaderHash);
@@ -409,8 +405,6 @@
 							//x_current.unlock();
 							//p_worktimer = new boost::asio::deadline_timer(m_io_service, boost::posix_time::seconds(m_worktimeout));
 							//p_worktimer->async_wait(boost::bind(&EthStratumClientV2::work_timeout_handler, this, boost::asio::placeholders::error));
-		
-							jobReport();			// display new job info
 						}
 					}
 				}
@@ -446,77 +440,75 @@
 }
 
 void EthStratumClientV2::work_timeout_handler(const boost::system::error_code& ec) {
-
-	cnote << "work_timeout_handler";
 	if (!ec) {
-		cnote << "No share response received in" << m_worktimeout << "milliseconds.";
+		cnote << "No new work received in" << m_worktimeout << "seconds.";
 		reconnect();
 	}
 }
 
-bool EthStratumClientV2::submit(EthashProofOfWork::Solution solution) {
+bool EthStratumClientV2::submit(Solution solution) {
+	x_current.lock();
+	WorkPackage tempWork(m_current);
+	string temp_job = m_job;
+	WorkPackage tempPreviousWork(m_previous);
+	string temp_previous_job = m_previousJob;
+	x_current.unlock();
 
-	cnote << "Submit solution to" << p_active->host;
+	cnote << "Solution found; Submitting to" << p_active->host << "...";
 
 	string minernonce;
-	if (m_protocol == STRATUM_PROTOCOL_ETHEREUMSTRATUM)
-		minernonce = solution.nonce.hex().substr(m_extraNonceHexSize, 16 - m_extraNonceHexSize);
+	if (m_protocol != STRATUM_PROTOCOL_ETHEREUMSTRATUM)
+		cnote << "  Nonce:" << "0x" + solution.nonce.hex();
 	else
-		minernonce = "0x" + solution.nonce.hex();
-
-	cdebug << "  Nonce:" << minernonce;
-
-	string json, jsonid, jobid, workHexHash;
+		minernonce = solution.nonce.hex().substr(m_extraNonceHexSize, 16 - m_extraNonceHexSize);
 
-	// m_socket.shutdown(boost::asio::ip::tcp::socket::shutdown_send); // for failure testing
 
-	if (EthashAux::eval(m_current.seedHash, m_current.headerHash, solution.nonce).value < m_current.boundary)
+	if (EthashAux::eval(tempWork.seedHash, tempWork.headerHash, solution.nonce).value < tempWork.boundary)
 	{
-		jsonid = "{\"id\": 4";
-		jobid = m_job;
-		workHexHash = m_current.headerHash.hex();
+		string json;
+		switch (m_protocol) {
+		case STRATUM_PROTOCOL_STRATUM:
+			json = "{\"id\": 4, \"method\": \"mining.submit\", \"params\": [\"" + p_active->user + "\",\"" + temp_job + "\",\"0x" + solution.nonce.hex() + "\",\"0x" + tempWork.headerHash.hex() + "\",\"0x" + solution.mixHash.hex() + "\"]}\n";
+			break;
+		case STRATUM_PROTOCOL_ETHPROXY:
+			json = "{\"id\": 4, \"worker\":\"" + m_worker + "\", \"method\": \"eth_submitWork\", \"params\": [\"0x" + solution.nonce.hex() + "\",\"0x" + tempWork.headerHash.hex() + "\",\"0x" + solution.mixHash.hex() + "\"]}\n";
+			break;
+		case STRATUM_PROTOCOL_ETHEREUMSTRATUM:
+			json = "{\"id\": 4, \"method\": \"mining.submit\", \"params\": [\"" + p_active->user + "\",\"" + temp_job + "\",\"" + minernonce + "\"]}\n";
+			break;
+		}
+		std::ostream os(&m_requestBuffer);
+		os << json;
+		m_stale = false;
+		write(m_socket, m_requestBuffer);
+		return true;
 	}
-	else if (EthashAux::eval(m_previous.seedHash, m_previous.headerHash, solution.nonce).value < m_previous.boundary)
+	else if (EthashAux::eval(tempPreviousWork.seedHash, tempPreviousWork.headerHash, solution.nonce).value < tempPreviousWork.boundary)
 	{
-		jsonid = "{\"id\": 6";
-		jobid = m_previousJob;
-		workHexHash = m_previous.headerHash.hex();
-
+		string json;
+		switch (m_protocol) {
+		case STRATUM_PROTOCOL_STRATUM:
+			json = "{\"id\": 4, \"method\": \"mining.submit\", \"params\": [\"" + p_active->user + "\",\"" + temp_previous_job + "\",\"0x" + solution.nonce.hex() + "\",\"0x" + tempPreviousWork.headerHash.hex() + "\",\"0x" + solution.mixHash.hex() + "\"]}\n";
+			break;
+		case STRATUM_PROTOCOL_ETHPROXY:
+			json = "{\"id\": 4, \"worker\":\"" + m_worker + "\", \"method\": \"eth_submitWork\", \"params\": [\"0x" + solution.nonce.hex() + "\",\"0x" + tempPreviousWork.headerHash.hex() + "\",\"0x" + solution.mixHash.hex() + "\"]}\n";
+			break;
+		case STRATUM_PROTOCOL_ETHEREUMSTRATUM:
+			json = "{\"id\": 4, \"method\": \"mining.submit\", \"params\": [\"" + p_active->user + "\",\"" + temp_previous_job + "\",\"" + minernonce + "\"]}\n";
+			break;
+		}		std::ostream os(&m_requestBuffer);
+		os << json;
+		m_stale = true;
 		cwarn << "Submitting stale solution.";
+		write(m_socket, m_requestBuffer);
+		return true;
 	}
 	else {
+		m_stale = false;
 		cwarn << "FAILURE: GPU gave incorrect result!";
 		p_farm->failedSolution();
-		return false;
-	}
-
-	switch (m_protocol) {
-	case STRATUM_PROTOCOL_STRATUM:
-		json = jsonid + ", \"method\": \"mining.submit\", \"params\": [\"" + p_active->user + "\",\"" + jobid + "\",\"" + minernonce + "\",\"0x" + workHexHash + "\",\"0x" + solution.mixHash.hex() + "\"]}\n";
-		break;
-	case STRATUM_PROTOCOL_ETHPROXY:
-		// Dwarf protocol
-		json = jsonid + ", \"worker\":\"" + m_worker + "\", \"method\": \"eth_submitWork\", \"params\": [\"" + minernonce + "\",\"0x" + workHexHash + "\",\"0x" + solution.mixHash.hex() + "\"]}\n";
-		break;
-	case STRATUM_PROTOCOL_ETHEREUMSTRATUM:
-		// NiceHash protocol
-		json = jsonid + ", \"method\": \"mining.submit\", \"params\": [\"" + p_active->user + "\",\"" + jobid + "\",\"" + minernonce + "\"]}\n";
-		break;
 	}
 
-	try{
-		cdebug << "Submitting share: " << json;	
-		std::ostream os(&m_requestBuffer);
-		os << json;
-		write(m_socket, m_requestBuffer);
-		m_worktimer.expires_from_now(boost::posix_time::milliseconds(m_worktimeout));
-	}
-		catch (std::exception const& _e) {
-			cwarn << "Share submit failed:" <<  _e.what();
-	}
-
-	// m_worktimer.async_wait(boost::bind(&EthStratumClientV2::work_timeout_handler, this, boost::asio::placeholders::error));
-
-	return true;
+	return false;
 }
 
diff -ru cpp-ethereum/libstratum/EthStratumClientV2.h ethminer.git/libstratum/EthStratumClientV2.h
--- cpp-ethereum/libstratum/EthStratumClientV2.h	2017-06-23 21:38:46.780605179 +0300
+++ ethminer.git/libstratum/EthStratumClientV2.h	2017-06-23 21:27:24.156627313 +0300
@@ -2,6 +2,7 @@
 #include <boost/array.hpp>
 #include <boost/asio.hpp>
 #include <boost/bind.hpp>
+#include <json/json.h>
 #include <libdevcore/Log.h>
 #include <libdevcore/FixedHash.h>
 #include <libdevcore/Worker.h>
@@ -18,15 +19,10 @@
 using namespace dev;
 using namespace dev::eth;
 
-// Json::Value is not part of the public interface 
-namespace Json {
-class Value;
-}
-
 class EthStratumClientV2 : public Worker
 {
 public:
-	EthStratumClientV2(GenericFarm<EthashProofOfWork> * f, MinerType m, string const & host, string const & port, string const & user, string const & pass, int const & retries, int const & worktimeout, int const & protocol, string const & email);
+	EthStratumClientV2(Farm* f, MinerType m, string const & host, string const & port, string const & user, string const & pass, int const & retries, int const & worktimeout, int const & protocol, string const & email);
 	~EthStratumClientV2();
 
 	void setFailover(string const & host, string const & port);
@@ -37,7 +33,7 @@
 	h256 currentHeaderHash() { return m_current.headerHash; }
 	bool current() { return m_current; }
 	unsigned waitState() { return m_waitState; }
-	bool submit(EthashProofOfWork::Solution solution);
+	bool submit(Solution solution);
 	void reconnect();
 private:
 	void workLoop() override;
@@ -68,14 +64,15 @@
 
 	string m_response;
 
-	GenericFarm<EthashProofOfWork> * p_farm;
-	//mutex x_current;
-	EthashProofOfWork::WorkPackage m_current;
-	EthashProofOfWork::WorkPackage m_previous;
+	Farm* p_farm;
+	mutex x_current;
+	WorkPackage m_current;
+	WorkPackage m_previous;
+
+	bool m_stale = false;
 
 	string m_job;
 	string m_previousJob;
-	EthashAux::FullType m_dag;
 
 	boost::asio::io_service m_io_service;
 	tcp::socket m_socket;
@@ -83,7 +80,7 @@
 	boost::asio::streambuf m_requestBuffer;
 	boost::asio::streambuf m_responseBuffer;
 
-	boost::asio::deadline_timer  m_worktimer;
+	boost::asio::deadline_timer * p_worktimer;
 
 	int m_protocol;
 	string m_email;
@@ -94,5 +91,4 @@
 	int m_extraNonceHexSize;
 
 	void processExtranonce(std::string& enonce);
-	void jobReport();
-};
+};
\ В конце файла нет новой строки
