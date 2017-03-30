/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using [java] org.apache.lucene
using [java] org.apache.lucene.analysis
using [java] org.apache.lucene.analysis.standard
using [java] org.apache.lucene.document
using [java] org.apache.lucene.store
using [java] org.apache.lucene.index
using [java] org.apache.lucene.util
using [java] org.apache.lucene.util::Version as LuceneVersion
using [java] org.apache.lucene.document::Field as IndexedField
using [java] org.apache.lucene.document::Field$Store as Store
using [java] org.apache.lucene.document::Field$Index as FieldIndex
using [java] org.apache.lucene.search
using [java] org.apache.lucene.queryParser

class RecordIndexer
{
  Project project
  Directory dir
  Analyzer analyzer

  new make(Project project)
  {
    this.project = project
    dir = RAMDirectory()
    analyzer = StandardAnalyzer(LuceneVersion.LUCENE_CURRENT)
  }



  Void index()
  {
    IndexWriterConfig config := IndexWriterConfig(LuceneVersion.LUCENE_CURRENT, analyzer)
    IndexWriter iwriter := IndexWriter(dir, config)
    Map records := project.database.getClassMap(Record#)
    records.each |V,K| {
      Document doc := Document()
      doc.add(IndexedField("id", K, Store.YES, FieldIndex.NO))
      doc.add(IndexedField("tags", V->data->map |Tag t-> Str| {return t.name+" "+t.val}->join(" "), Store.NO, FieldIndex.ANALYZED))
      //echo(V->data->map |Tag t-> Str| {return t.name}->join(" "))
      V->data->each | tag |{
        if(tag->val!=null)
        {
          doc.add(IndexedField(tag->name, tag->val.toStr, Store.NO, FieldIndex.ANALYZED))
        }
        else
        {
          doc.add(IndexedField(tag->name, "null", Store.NO, FieldIndex.ANALYZED))
        }
      }
      iwriter.addDocument(doc);
    }
    iwriter.close();
  }

  Str:Str search(Str strquery)
  {
    IndexReader ireader := IndexReader.open(dir)
    IndexSearcher isearcher := IndexSearcher(ireader)
    try
    {
    QueryParser parser := QueryParser(LuceneVersion.LUCENE_CURRENT,"tags", analyzer)
    Query query := parser.parse(strquery)
    ScoreDoc[] hits := isearcher.search(query, null, 1000).scoreDocs
    Str:Str recordMap := [:]
    hits.each |hit|
    {
      Document hitDoc := isearcher.doc(hit.doc)
      Str id := hitDoc.get("id")
      recordMap.add(id,id)
    }
    return recordMap
    }
    finally{
    isearcher.close
    ireader.close
    }
  }

  Void reindex()
  {
    close
    dir = RAMDirectory()
    analyzer = StandardAnalyzer(LuceneVersion.LUCENE_CURRENT)
    index
  }

  Void close()
  {
    dir.close
  }



}
