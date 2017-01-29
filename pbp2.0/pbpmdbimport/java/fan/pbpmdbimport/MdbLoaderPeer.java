package fan.pbpmdbimport;

import com.healthmarketscience.jackcess.Database;
import com.healthmarketscience.jackcess.DatabaseBuilder;
import com.healthmarketscience.jackcess.Row;
import com.healthmarketscience.jackcess.Table;
import fanx.interop.*;
import java.io.File;
import java.util.Date;

/**
 * @author 
 * @version $Revision:$
 */
public class MdbLoaderPeer {
    public static MdbLoaderPeer make(MdbLoader self) {
        return new MdbLoaderPeer();
    }


    static fan.sys.List loadTable(fan.sys.File dbFile, String tableName) {
        fan.sys.List lst = fan.sys.List.make(Interop.toFan(fan.sys.Map.class), 0);

        Database db = null;
        try {
            db = DatabaseBuilder.open(new File(dbFile.pathStr()));
            Table table = db.getTable(tableName);
            if (table != null) {
                for (Row row : table) {
                    fan.sys.Map map = new fan.sys.Map(Interop.toFan(String.class), Interop.toFan(Object.class));
                    map.ordered(true);

                    for (String key : row.keySet()) {
                        final Object value = row.get(key);
                        map.add(key, toFantom(value));
                    }
                    lst.add(map);
                }
            }
        } catch (java.lang.Exception exception) {
            System.out.println("error " + exception.getMessage());
            exception.printStackTrace();
        }
        finally {
            if(db != null){
                try {
                    db.close();
                } catch (java.lang.Exception exception) {
                    exception.printStackTrace();
                }
            }
        }

        return lst;
    }


    private static Object toFantom(Object value) {
        if (value instanceof Date) {
            try {
                return fan.sys.DateTime.fromJava(((Date) value).getTime());
            } catch (java.lang.Exception exception) { // ugly hack to work around limitations of Fantom DateTime class
                return value.toString();
            }
        }
        if (value instanceof Integer) {
            return ((Integer) value).longValue();
        }
        else if (value instanceof Short) {
            return ((Short) value).longValue();
        }
        return value;
    }

}
