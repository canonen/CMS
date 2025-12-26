<%@page
        language="java"
        import="com.britemoon.*,
        		com.britemoon.rcp.*,
        		com.britemoon.rcp.imc.*,
        		com.britemoon.rcp.que.*,
        		java.sql.DriverManager,
        		java.sql.*,
        		java.io.*,
        		java.math.BigDecimal,
        		java.text.NumberFormat,
        		java.util.Date,
        		java.io.*,
        		java.text.DateFormat,
        		java.text.SimpleDateFormat,
        		org.apache.log4j.Logger,
        		org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="org.apache.lucene.document.Document" %>
<%@ page import="org.apache.lucene.analysis.standard.StandardAnalyzer" %>
<%@ page import="org.apache.lucene.store.Directory" %>
<%@ page import="org.apache.lucene.store.ByteBuffersDirectory" %>
<%@ page import="org.apache.lucene.index.IndexWriterConfig" %>
<%@ page import="org.apache.lucene.index.IndexWriter" %>
<%@ page import="org.apache.lucene.search.Query" %>
<%@ page import="org.apache.lucene.queryparser.classic.QueryParser" %>
<%@ page import="org.apache.lucene.index.IndexReader" %>
<%@ page import="org.apache.lucene.index.DirectoryReader" %>
<%@ page import="org.apache.lucene.search.IndexSearcher" %>
<%@ page import="org.apache.lucene.search.TopDocs" %>
<%@ page import="org.apache.lucene.search.ScoreDoc" %>
<%@ page import="org.apache.lucene.document.Document" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
%>
<%
    private static  addDoc(IndexWriter w, String title, String isbn) throws IOException {
    Document doc = new Document();
    doc.add(new TextField("title", title, Field.Store.YES));

    // use a string field for isbn because we don't want it tokenized
    doc.add(new StringField("isbn", isbn, Field.Store.YES));
    w.addDocument(doc);
    }
    // 0. Specify the analyzer for tokenizing text.
    //    The same analyzer should be used for indexing and searching
    StandardAnalyzer analyzer = new StandardAnalyzer();
    // 1. create the index
    Directory index = new ByteBuffersDirectory();

    IndexWriterConfig configg = new IndexWriterConfig(analyzer);

    IndexWriter w = new IndexWriter(index, configg);
    addDoc(w, "Lucene in Action", "193398817");
    addDoc(w, "Lucene for Dummies", "55320055Z");
    addDoc(w, "Managing Gigabytes", "55063554A");
    addDoc(w, "The Art of Computer Science", "9900333X");
    w.close();

    // 2. query
    String querystr = args.length > 0 ? args[0] : "lucene";

    // the "title" arg specifies the default field to use
    // when no field is explicitly specified in the query.
    Query q = new QueryParser("title", analyzer).parse(querystr);

    // 3. search
    int hitsPerPage = 10;
    IndexReader reader = DirectoryReader.open(index);
    IndexSearcher searcher = new IndexSearcher(reader);
    TopDocs docs = searcher.search(q, hitsPerPage);
    ScoreDoc[] hits = docs.scoreDocs;

    // 4. display results
    System.out.println("Found " + hits.length + " hits.");
    for(int i=0;i<hits.length;++i) {
        int docId = hits[i].doc;
        Document d = searcher.doc(docId);
        System.out.println((i + 1) + ". " + d.get("isbn") + "\t" + d.get("title"));
    }

    // reader can only be closed when there
    // is no need to access the documents any more.
    reader.close();
    }


%>