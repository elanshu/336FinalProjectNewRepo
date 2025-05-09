<%@ page import="java.sql.*, java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.*, javax.servlet.http.*" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Answer Customer Questions</title>
</head>
<body>
	
	<!-- home page button -->
	<a href="http://localhost:8080/336FinalProjectNewRepo-main_336FinalProject/repHome.jsp" class="back-button">Go to home page</a>
	
    <h1>Answer Customer Questions</h1>

	<!-- search feature -->
    <div class="search-form">
        <form method="get" action="repAnswerQuestions.jsp">
            <label for="keyword">Search Q&A:</label>
            <input type="text" id="keyword" name="keyword" value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
            <input type="submit" value="Search">
        </form>
    </div>
	
    <!-- questions and answers -->
    <div class="qa-section">
    
<%
	// connects to database
	Class.forName("com.mysql.jdbc.Driver");
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/336AirlineProject", "root", "mysqlpassword");
	
	// checks to see if the 
	
	// reads off all the questions and answers based search function keyword (if it's not empty)
	String keyword = request.getParameter("keyword");
	PreparedStatement filteredQAs;
		
	// filter the search by the keyword input whether it's found in the question or answer (case insensitive)
	// Also keep track of id value, this will play a role later in which queries to edit and delete
	if (keyword != null && !keyword.trim().isEmpty()) {
		filteredQAs = con.prepareStatement("SELECT id, question, answer FROM QA WHERE question LIKE ? OR answer LIKE ?");
		String SQLkeyword = "%" + keyword + "%";
		filteredQAs.setString(1, SQLkeyword);
		filteredQAs.setString(2, SQLkeyword);
	} else {
		filteredQAs = con.prepareStatement("SELECT id, question, answer FROM QA");
	}
		
	// gives the query to which we iterate through
	ResultSet QAiterator = filteredQAs.executeQuery();
	    			
	// posts all questions and answers
	
	int qaIDtoEdit = -1; // initialize to anything below 0 to make sure we don't get any row of the query
	int qaIDtoDelete = -1; // we do something similar when we delete
	
	String editClicked = request.getParameter("editID");
	String saveClicked = request.getParameter("saveID");
	String deleteClicked = request.getParameter("deleteID");
	
	// if edit button has been clicked, then we store the qaID we wish to edit later
	if (editClicked != null) {
		qaIDtoEdit = Integer.parseInt(editClicked);
	}
	
	// if delete button has been clicked, then we store the qaID we wish to delete later
	if (deleteClicked != null) {
		qaIDtoDelete = Integer.parseInt(deleteClicked);
		PreparedStatement deleteQuery = con.prepareStatement("DELETE FROM QA WHERE id = ?");
		deleteQuery.setInt(1, qaIDtoDelete);
		deleteQuery.executeUpdate();
		deleteQuery.close();
		
		// immediately re-run the query to refresh the page to display the edited answer, else you have to refesh the entire page to see the edits
		if (keyword != null && !keyword.trim().isEmpty()) {
			filteredQAs = con.prepareStatement("SELECT id, question, answer FROM QA WHERE question LIKE ? OR answer LIKE ?");
			String SQLkeyword = "%" + keyword + "%";
			filteredQAs.setString(1, SQLkeyword);
			filteredQAs.setString(2, SQLkeyword);
		} else {
			filteredQAs = con.prepareStatement("SELECT id, question, answer FROM QA");
		}

		QAiterator = filteredQAs.executeQuery();
	}
	
	// if the save button has been clicked, we update the corresponding information in the query
	if (saveClicked != null) {
		int qaIDtoSave = Integer.parseInt(saveClicked);
		String editedAnswer = request.getParameter("editedAnswer");
		
		PreparedStatement updatedQuery = con.prepareStatement("UPDATE QA SET answer = ? WHERE id = ?");
		updatedQuery.setString(1, editedAnswer);
		updatedQuery.setInt(2, qaIDtoSave);
		updatedQuery.executeUpdate();
		updatedQuery.close();
		
		// immediately re-run the query to refresh the page to display the edited answer, else you have to refesh the entire page to see the edits
		if (keyword != null && !keyword.trim().isEmpty()) {
			filteredQAs = con.prepareStatement("SELECT id, question, answer FROM QA WHERE question LIKE ? OR answer LIKE ?");
			String SQLkeyword = "%" + keyword + "%";
			filteredQAs.setString(1, SQLkeyword);
			filteredQAs.setString(2, SQLkeyword);
		} else {
			filteredQAs = con.prepareStatement("SELECT id, question, answer FROM QA");
		}

		QAiterator = filteredQAs.executeQuery();
		
	}
	
	while (QAiterator.next()) {
		int qaID = QAiterator.getInt("id");
	   	String q = QAiterator.getString("question");
		String a = QAiterator.getString("answer");
%>
		<!-- lists all questions and answers. Allows you delete a chosen question or edit a chosen answer -->
	   	<div class="qa">
	   		
	   		
	   		<!-- pre-clicked delete button -->
	   		<form method="post" action="repAnswerQuestions.jsp">
	   			
                <p> <input type="hidden" name="deleteID" value="<%= qaID %>"> <input type="submit" value="Delete"> <strong>Q: </strong><%=q%></p>
           
            </form>
	   		
	   		 <% if (qaIDtoEdit == qaID) { %>
	   		   
	   		   <!-- post-clicked edit button scenario -->
            	<form method="post" action="repAnswerQuestions.jsp">
            	
                	<p> <input type="hidden" name="saveID" value="<%= qaID %>"> <textarea name="editedAnswer" rows="2" cols="100"><%= a %></textarea><br> <input type="submit" value="Save"> </p>
                	
            	</form>

	   		<% } else { %>
	   		
	   			<!-- pre-clicked edit button scenario -->
	   			<form method="post" action="repAnswerQuestions.jsp">
	   			
                	<p> <input type="hidden" name="editID" value="<%=qaID %>"> <input type="submit" value="Edit"> <strong>A: </strong><%=a%></p>
           
            	</form>
	   		<% } %>
	   		
	   	</div>
	   	
<% 
	}
		
	QAiterator.close();
	filteredQAs.close();
	con.close();
		
%>	

</body>
</html>
