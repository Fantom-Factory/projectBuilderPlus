package fan.pbpcore;

import fan.sys.*;
import fan.sys.List;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.Directory;
import org.apache.lucene.util.Version;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.store.RAMDirectory;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import java.io.File;

public class IndexerPeer
{
  public fan.pbpcore.Indexer self;
  private IndexWriter iwriter;
  private Directory directory;
  private Analyzer analyzer;

   public static IndexerPeer make(fan.pbpcore.Indexer self) throws java.io.IOException
  {
    IndexerPeer peer = new IndexerPeer();
    peer.self = self;
    return peer;
  }
/*
  TODO: try tossing in the string in the constructor
*/
  private IndexerPeer() throws org.apache.lucene.index.CorruptIndexException, java.io.IOException
  {
    analyzer = new StandardAnalyzer(Version.LUCENE_CURRENT);
    String filepath = Env.cur().homeDir().pathStr()+"etc/indexer/dump/";
    directory = FSDirectory.open(new File(filepath)); //new RAMDirectory();

  }

  public void index(fan.pbpcore.Indexer self) throws org.apache.lucene.index.CorruptIndexException, java.io.IOException
  {
    iwriter = new IndexWriter(directory,  analyzer, true, new IndexWriter.MaxFieldLength(25000));
    return;
  }

  void addDoc(fan.pbpcore.Indexer self, String fieldname, String text/*fan.pbpcore.Doc doc*/)  throws org.apache.lucene.index.CorruptIndexException, java.io.IOException
  {
    if(!IndexWriter.isLocked(directory))
    {
      IndexWriter.unlock(directory);
      System.out.println("unlocking");
    }
    Document doc = new Document();
    doc.add(new Field(fieldname, text, Field.Store.YES, Field.Index.ANALYZED));
    iwriter.addDocument(doc);
  }
/*
  void updateDoc(fan.pbpcore.Indexer self, String fieldname, String lequery)
  {
    IndexReader ireader = IndexReader.open(directory);
    IndexSearcher isearcher = new IndexSearcher(ireader);
    QueryParser parser = new QueryParser(Version.LUCENE_CURRENT,fieldname, analyzer);
    Query thequery = parser.parse(lequery);
    ScoreDoc[] hits = isearcher.search(thequery, null, 1000).scoreDocs;

    iwriter.updateDocument(Term(fieldname, text), hits[0])

  }
*/
  String query(fan.pbpcore.Indexer self, String fieldname, String lequery) throws org.apache.lucene.index.CorruptIndexException, org.apache.lucene.queryParser.ParseException, java.io.IOException
  {
    IndexReader ireader = IndexReader.open(directory);
    IndexSearcher isearcher = new IndexSearcher(ireader);
    QueryParser parser = new QueryParser(Version.LUCENE_CURRENT,fieldname, analyzer);
    Query thequery = parser.parse(lequery);
    ScoreDoc[] hits = isearcher.search(thequery, null, 1000).scoreDocs;
    try
    {
    if(hits.length > 0)
    {
      //return "true";
      return isearcher.doc(hits[0].doc).get(fieldname);
    }
    else
    {
      return "false";
    }
    }
    finally
    {
    ireader.close();
    }
    }

   public void close(fan.pbpcore.Indexer self) throws org.apache.lucene.index.CorruptIndexException, java.io.IOException
   {
     iwriter.close();
   }

  }




