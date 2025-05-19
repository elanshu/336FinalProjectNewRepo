<%@ page import="java.sql.*, java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.*, javax.servlet.http.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Questions and Answers</title>
</head>
<body>
	
	<!-- home page button -->
	<a href="http://localhost:8080/336FinalProjectNewRepo-main_336FinalProject/customerHome.jsp" class="back-button">Go to home page</a>
	
    <h1>Questions and Answers</h1>

	<!-- search feature -->
    <div class="search-form">
        <form method="get" action="customerQA.jsp">
            <label for="keyword">Search Q&A:</label>
            <input type="text" id="keyword" name="keyword" value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
            <input type="submit" value="Search">
        </form>
    </div>
	
    <!-- questions and answers -->
    <div class="qa-section">
    
<%
	// inserts the question into a database through the QA table
	String postQuestion = request.getParameter("question");

	// connects to database
	Class.forName("com.mysql.jdbc.Driver");
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/336AirlineProject", "root", "mysqlpassword");
		
	// make sure the postQuestion isn't null else everytime you refresh it sends output
	if (postQuestion != null && !postQuestion.trim().isEmpty()) {
		PreparedStatement qaToAdd = con.prepareStatement("INSERT INTO QA (question, answer) VALUES (?, ?)");
		qaToAdd.setString(1, postQuestion);
		qaToAdd.setString(2, "Waiting for a customer representative to respond..."); // default output
		qaToAdd.executeUpdate();
	}
			
	// reads off all the questions and answers based search function keyword (if it's not empty)
	String keyword = request.getParameter("keyword");
	PreparedStatement filteredQAs;
	
	// filter the search by the keyword input whether it's found in the question or answer (case insensitive)
	if (keyword != null && !keyword.trim().isEmpty()) {
		filteredQAs = con.prepareStatement("SELECT question, answer FROM QA WHERE question LIKE ? OR answer LIKE ?");
		String SQLkeyword = "%" + keyword + "%";
		filteredQAs.setString(1, SQLkeyword);
		filteredQAs.setString(2, SQLkeyword);
	} else {
		filteredQAs = con.prepareStatement("SELECT question, answer FROM QA");
	}
	
	// gives the query to which we iterate through
    ResultSet QAiterator = filteredQAs.executeQuery();
    			
   	// posts all questions and answers
   	while (QAiterator.next()) {
   		String q = QAiterator.getString("question");
   		String a = QAiterator.getString("answer");
%>
   		<div class="qa">
   			<p><strong>Q: </strong><%=q%></p>
   			<p><strong>A: </strong><%=a%></p>
   		</div>
<% 
   	}
	
   	QAiterator.close();
   	filteredQAs.close();
	con.close();
	
%>

    </div>

    <!-- post questions -->
    <div class="form-section">
        <h2>Ask a Question</h2>
        <form action="customerQA.jsp" method="post">
            <label for="answer">Post a Question (a customer representative will get back to you shortly):</label><br>
            <textarea id="question" name="question" required></textarea><br><br>
            <input type="submit" value="Submit Q&A">
        </form>
    </div>
    

</body>
</html>
