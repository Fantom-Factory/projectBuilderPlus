package fan.pbpnhaystack;

import org.projecthaystack.HGridBuilder;
import org.projecthaystack.HVal;

import java.util.ArrayList;
import java.util.List;

/**
 * @author 
 * @version $Revision:$
 */
public class HaystackUtilsPeer {

    public static HaystackUtilsPeer make(HaystackUtils self) { return new HaystackUtilsPeer(); }

    static void addRow(HGridBuilder gridBuilder, fan.sys.List data)
    {
        List<HVal> items = new ArrayList<HVal>();
        for (Object o : data.toArray()) {
            if (o instanceof HVal) {
                items.add((HVal) o);
            }
        }

        gridBuilder.addRow(items.toArray(new HVal[items.size()]));

    }

}
