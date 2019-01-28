import com.sun.awt.AWTUtilities;
import com.sun.jna.Native;
import com.sun.jna.platform.win32.User32;
import com.sun.jna.platform.win32.WinDef.HWND;
import java.awt.event.ActionListener;
import java.awt.event.MouseListener;
import java.awt.event.ActionEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GridLayout;
import java.awt.Image;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.PointerInfo;
import java.awt.PopupMenu;
import java.awt.SystemTray;
import java.awt.Toolkit;
import java.awt.TrayIcon;
import java.awt.TrayIcon.MessageType;
import java.awt.Window;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.BufferedInputStream;
import java.net.URL;
import java.net.URLConnection;
import java.net.HttpURLConnection;
import java.util.Calendar;
import java.util.Scanner;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.prefs.Preferences;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.JSlider;
import javax.swing.JTextArea;
import javax.swing.JDialog;
import javax.swing.SwingUtilities;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.FileNotFoundException;


String urlStr = "http://content.warframe.com/dynamic/worldState.php"; 
String php = ""; 
String dialImage = "dial.png"; 
String frameImage = "frame.png";

long unixTime = System.currentTimeMillis();


JFrame settings = new JFrame("Settings");
JPanel sPanel = new JPanel();
JButton move = new JButton("Move");
JCheckBox cbShowIn = new JCheckBox("Show only ingame");
JSlider opSlider = new JSlider();
JSlider sizeSlider = new JSlider();


WinDef.HWND hwnd;


JFrame jW = new JFrame();
JLabel jL = new JLabel();
JLabel iL = new JLabel();
JLabel iL2 = new JLabel();
BufferedImage dialImg = null; 
BufferedImage frameImg = null; 
BufferedImage sImg = null;


boolean show = true; 
boolean moving = false; 
boolean resizing = false;


final SystemTray tray = SystemTray.getSystemTray();
final PopupMenu popup = new PopupMenu();

Preferences prefs = Preferences.userRoot().node("cetus_timer");


final String prefShowIngame = "cetus_timer_only_ingame"; 
boolean onlyIngame = false;
final String prefOpacity = "cetus_timer_opacity"; 
float opacity = 0.75F;
final String prefSize = "cetus_timer_size"; 
float defSize = 0.755F; 
float size = defSize;
final String prefPos = "cetus_timer_pos";
final String prefFirstConfig = "cetus_timer_first_config"; 
boolean firstConfig = false;


int wlDefault;

boolean day;

boolean top;

TrayIcon trayIcon;
String pos;
BufferedReader reader;
String line;
String link;
String zipName;
Scanner r;
String repoVer;
boolean bool;
private String INPUT_ZIP_FILE;
private String OUTPUT_FOLDER;
private String TEMP_FOLDER;
JFrame frame;
JPanel pane;
JLayeredPane propane;
JTextArea texta;

final String prefOnUpdate = "cetus_on_update"; 
boolean onUpdateDefault = false;

public boolean dlPending = false;

String[] lines = new String[1];

String currentVer = "1.0.0";

String patchNotes = "";

private final int BUFFER_SIZE = 4096;

Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
int swidth = (int)screenSize.getWidth();
int sheight = (int)screenSize.getHeight();

JProgressBar jProgressBar = new JProgressBar();

JButton updateBtn = new JButton("Update");
long timeStart;

long timeNight;
long timeEnd;
Calendar curTime;
Calendar nightTime;
Calendar endTime;
int time;

public void reconnect() throws Exception {
  try { 
    php = "";

    println("php get");

    URL url = new URL(urlStr);
    URLConnection conn = url.openConnection();
    InputStream is = conn.getInputStream();
    Scanner s = new Scanner(is);
    while (s.hasNext()) {
      php += s.next();
      Thread.sleep(5L);
    }

    String spl = split(php, "\"}},\"Tag\":\"CetusSyndicate\"")[0];
    String[] oidSpl = split(spl, "\"$oid\":");
    String[] numberSpl = split(oidSpl[(oidSpl.length - 1)], "$numberLong\":\"");
    timeStart = Long.parseLong(numberSpl[1].split("\"", 0)[0]);
    timeEnd = Long.parseLong(numberSpl[2].split("\"", 0)[0]);
    timeNight = (timeEnd - (timeEnd - timeStart) / 3L);

    nightTime.setTimeInMillis(timeNight);
    endTime.setTimeInMillis(timeEnd);

    s.close();
    is.close();

    println("php done");

    frameRate(1.0F);
  } 
  catch (Exception e) { 
    throw e;
  }
}

public void tryConnection(int i)
{
  if (i == 0)
  try {
    reconnect();
  } 
  catch (Exception e) { 
    e.printStackTrace();
    tryConnection(1);
  }
  if (i == 1)
  try {
    reconnect();
    Thread.sleep(5000L);
  } 
  catch (Exception e) { 
    e.printStackTrace();
    tryConnection(1);
  }
}

public void moveJW() { 
  while (moving) {
    jW.setLocation(MouseInfo.getPointerInfo().getLocation().x - jW.getWidth() / 2, MouseInfo.getPointerInfo().getLocation().y - jW.getHeight() / 2);
    if (jW.getX() <= 0) jW.setLocation(0, jW.getLocation().y);
    if (jW.getX() + jW.getWidth() >= displayWidth) jW.setLocation(displayWidth - jW.getWidth(), jW.getLocation().y);
    if (jW.getY() <= 0) jW.setLocation(jW.getLocation().x, 0);
    if (jW.getY() + jW.getHeight() >= displayHeight) { 
      jW.setLocation(jW.getLocation().x, displayHeight - jW.getHeight());
    }
    if (jW.getY() + jW.getHeight() / 2 <= displayHeight / 2) top = true; 
    else top = false;
    repaint();
    try {
      Thread.sleep(100L);
    } 
    catch (Exception localException) {
    }
  }
}

public void showSmooth() { 
  if (!show) {
    for (float i = 0.0F; i < prefs.getFloat("cetus_timer_opacity", opacity); i += 0.1F) {
      try {
        Thread.sleep(50L);
      } 
      catch (Exception localException) {
      }
      jW.setOpacity(i);
    }
  }
  show = true;
  jW.setOpacity(prefs.getFloat("cetus_timer_opacity", opacity));
}

public void hideSmooth() {
  if (show) {
    for (float i = prefs.getFloat("cetus_timer_opacity", opacity); i > 0.0F; i -= 0.1F) {
      try {
        Thread.sleep(50L);
      } 
      catch (Exception localException) {
      }
      jW.setOpacity(i);
    }
  }
  show = false;
  jW.setOpacity(0.0F);
}

public void setup() {
  surface.setLocation(-90000, -90000);
  surface.setVisible(false);
  surface.setTitle("Plains of Eidolon Clock");
  jW.setTitle("Plains of Eidolon Clock");

  frameRate(0.0F);

  Logger.getLogger("com.gargoylesoftware").setLevel(Level.OFF);

  curTime = Calendar.getInstance();
  nightTime = Calendar.getInstance();
  endTime = Calendar.getInstance();

  curTime.setTimeInMillis(unixTime);

  cbShowIn.setSelected(prefs.getBoolean("cetus_timer_only_ingame", onlyIngame));

  size = prefs.getFloat("cetus_timer_size", defSize);

  pos = str(parseInt(displayWidth / 2 - 163.0F * size / 2.0F)) + ",0";

  move.addActionListener(new ActionListener() {
    @Override
      public void actionPerformed(ActionEvent e) {
      if (!show) {
        thread("showSmooth");
      }
      //cetusTimer.access(, (boolean)false);
      moving = true;
      thread("moveJW");
    }
  }
  );
  move.setVisible(true);

  cbShowIn.addActionListener(new ActionListener() {
    @Override
      public void actionPerformed(ActionEvent e) {
      if (!cbShowIn.isSelected()) {
        thread("showSmooth");
        prefs.putBoolean("cetus_timer_only_ingame", false);
      } else {
        thread("hideSmooth");
        prefs.putBoolean("cetus_timer_only_ingame", true);
      }
    }
  }
  );
  cbShowIn.setVisible(true);

  opSlider.setValue(parseInt(prefs.getFloat("cetus_timer_opacity", opacity) * 100.0F));
  opSlider.setMaximum(100);
  opSlider.addChangeListener(new ChangeListener() {
    @Override
      public void stateChanged(ChangeEvent e) {
      prefs.putFloat("cetus_timer_opacity", (float)opSlider.getValue() / 100.0f);
      if (show) {
        jW.setOpacity((float)opSlider.getValue() / 100.0f);
        try {
          Thread.sleep(100);
        }
        catch (Exception exception) {
        }
      }
    }
  }
  );

  sizeSlider.setValue(parseInt(size * 100.0F));
  sizeSlider.setMinimum(50);
  sizeSlider.setMaximum(100);
  sizeSlider.addMouseListener(new MouseAdapter() {
    @Override
      public void mousePressed(MouseEvent evt) {
      resizing = true;
    }

    @Override
      public void mouseReleased(MouseEvent evt) {
      resizing = false;
    }
  }
  );

  sizeSlider.addChangeListener(new ChangeListener() {
    @Override
      public void stateChanged(ChangeEvent e) {
      prefs.putFloat("cetus_timer_size", (float)sizeSlider.getValue() / 100.0f);
      if (show) {
        size = (float)sizeSlider.getValue() / 100.0f;
        repaint();
        try {
          Thread.sleep(100);
        }
        catch (Exception exception) {
        }
      }
    }
  }
  );

  sPanel.add(move);
  sPanel.add(cbShowIn);
  sPanel.add(new JLabel("Opacity"));
  sPanel.add(opSlider);
  sPanel.add(new JLabel("Size"));
  sPanel.add(sizeSlider);

  settings.add(sPanel);

  settings.setResizable(false);
  settings.setSize(230, 148);
  settings.setPreferredSize(new Dimension(230, 135));
  settings.setLocationRelativeTo(null);

  if (!prefs.getBoolean("cetus_timer_first_config", firstConfig)) {
    settings.setVisible(true);
    settings.addWindowListener(new WindowAdapter() {
      @Override
        public void windowClosing(WindowEvent e) {
        settings.setVisible(false);
        if (!prefs.getBoolean("cetus_timer_first_config", firstConfig)) {
          JOptionPane j = new JOptionPane("The program will stay running. Go to the tray to change settings, or close it.", 1, -1);
          JDialog d = j.createDialog("Plains of Eidolon Clock");
          try {
            URL url = this.getClass().getResource("\\image\\tray.png");
            Image img = Toolkit.getDefaultToolkit().getImage(url).getScaledInstance(16, 16, 4);
            d.setIconImage(img);
          }
          catch (Exception exception) {
            try {
              Image img = Toolkit.getDefaultToolkit().getImage(String.valueOf(sketchPath()) + "\\image\\tray.png").getScaledInstance(16, 16, 4);
              d.setIconImage(img);
            }
            catch (Exception exception2) {
            }
          }
          d.setVisible(true);
          prefs.putBoolean("cetus_timer_first_config", true);
        }
      }
    }
    );
  }
  try
  {
    try
    {
      URL url = getClass().getResource("/image/tray.png");

      Image img = Toolkit.getDefaultToolkit().getImage(url).getScaledInstance(16, 16, 4);
      settings.setIconImage(img);
      trayIcon = new TrayIcon(img, 
        "Plains of Eidolon Clock");
    } 
    catch (Exception localException1) {
      try {
        Image img = Toolkit.getDefaultToolkit().getImage(sketchPath() + "\\image\\tray.png").getScaledInstance(16, 16, 4);
        settings.setIconImage(img);
        trayIcon = new TrayIcon(img, "Plains of Eidolon Clock");
      }
      catch (Exception localException2) {
      }
    }
    try {
      dialImg = ImageIO.read(getClass().getResource("/image/" + dialImage));
    } 
    catch (Exception localException3) {
      println("no image found, trying debug");
      try {
        dialImg = ImageIO.read(new File(sketchPath() + "/image/" + dialImage));
      }
      catch (Exception localException4) {
      }
    }
    try {
      frameImg = ImageIO.read(getClass().getResource("/image/" + frameImage));
    } 
    catch (Exception localException5) {
      println("no image found, trying debug");
      try {
        frameImg = ImageIO.read(new File(sketchPath() + "/image/" + frameImage));
      }
      catch (Exception localException6) {
      }
    }
    popup.add("Settings");
    popup.add("Close");

    popup.addActionListener(new ActionListener() {
      @Override
        public void actionPerformed(ActionEvent e) {
        if (e.getActionCommand().equals("Settings")) {
          settings.setVisible(true);
        }
        if (e.getActionCommand().equals("Close")) {
          System.exit(0);
        }
      }
    }
    );

    trayIcon.setPopupMenu(popup);

    trayIcon.addMouseListener(new MouseAdapter() {
      @Override
        public void mouseClicked(MouseEvent evt) {
        if (evt.getClickCount() >= 2) {
          settings.setVisible(true);
          settings.toFront();
        }
      }
    }
    );

    tray.add(trayIcon);

    repaint();
  }
  catch (Exception localException7) {
  }

  jW.setLayout(null);

  jW.setLocation(parseInt(prefs.get("cetus_timer_pos", pos).split(",")[0]), parseInt(prefs.get("cetus_timer_pos", pos).split(",")[1]));
  jW.setSize(parseInt(163.0F * size), parseInt(120.0F * size));
  jW.setType(Window.Type.UTILITY);

  jW.setUndecorated(true);
  jW.setAlwaysOnTop(true);
  jW.setFocusable(false);

  AWTUtilities.setWindowOpaque(jW, false);

  if (cbShowIn.isSelected()) {
    show = false;
    jW.setOpacity(0.0F);
  } else {
    show = true;
    jW.setOpacity(prefs.getFloat("cetus_timer_opacity", opacity));
  }

  jL.setFocusable(false);
  jL.setText("Getting time.");
  jL.setForeground(new Color(0, 0, 0));
  jL.setHorizontalAlignment(0);
  jL.setFont(new Font("Arial", 1, parseInt(20.0F * size)));
  jL.setBounds(0, top ? 0 : parseInt(91.0F * size), parseInt(163.0F * size), parseInt(30.0F * size));

  iL.setSize(parseInt(frameImg.getWidth()), parseInt(frameImg.getHeight()));
  iL2.setSize(parseInt(dialImg.getWidth()), parseInt(dialImg.getHeight()));
  iL2.setLocation(parseInt(10.0F * size), parseInt(12.0F * size));

  jW.add(jL);
  jW.add(iL);
  jW.add(iL2);

  jW.addMouseListener(new MouseAdapter() {
    @Override
      public void mouseReleased(MouseEvent e) {
      moving = false;
      prefs.put("cetus_timer_pos", String.valueOf(jW.getX()) + "," + jW.getY());
      //cetusTimer.access((cetusTimer)cetusTimer.this, (boolean)true);
    }
  }
  );

  jW.setVisible(true);

  hwnd = getHWnd(jW);
  wlDefault = User32.INSTANCE.GetWindowLong(hwnd, -20);
  wlDefault |= 0x80000;

  setTransparent(true);

  tryUpdate();

  tryConnection(0);
}

private void setTransparent(boolean bool) {
  if (bool) {
    int wl = User32.INSTANCE.GetWindowLong(hwnd, -20);
    wl = wl | 0x80000 | 0x20;
    User32.INSTANCE.SetWindowLong(hwnd, -20, wl);
  } else {
    int wl = wlDefault;
    User32.INSTANCE.SetWindowLong(hwnd, -20, wl);
  }
}



private static WinDef.HWND getHWnd(Component w)
{
  WinDef.HWND hwnd = new WinDef.HWND();
  hwnd.setPointer(Native.getComponentPointer(w));
  return hwnd;
}

public void repaint() {
  unixTime = System.currentTimeMillis();
  curTime.setTimeInMillis(unixTime);

  if (jW.getY() + jW.getHeight() / 2 <= displayHeight / 2) top = true; 
  else { 
    top = false;
  }
  if (unixTime <= timeNight) day = true; 
  else { 
    day = false;
  }

  long millis = day ? nightTime.getTimeInMillis() - curTime.getTimeInMillis() : endTime.getTimeInMillis() - curTime.getTimeInMillis();

  String hour = String.format("%02d", new Object[] {
    Long.valueOf(TimeUnit.MILLISECONDS.toHours(millis)) });
  String minute = String.format("%02d", new Object[] {
    Long.valueOf(TimeUnit.MILLISECONDS.toMinutes(millis) - 
    TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis))) });
  String second = String.format("%02d", new Object[] {
    Long.valueOf(TimeUnit.MILLISECONDS.toSeconds(millis) - 
    TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis))) });

  if (resizing) {
    jW.setLocation(jW.getX() + jW.getWidth() / 2, jW.getY());
    jW.setSize(parseInt(163.0F * size), parseInt(120.0F * size));
    jW.setLocation(jW.getX() - jW.getWidth() / 2, jW.getY());
  }

  jL.setText(hour + ":" + minute + ":" + second);

  iL2.setLocation(parseInt(9.0F * size), parseInt(12.0F * size));

  jL.setFont(new Font("Arial", 1, parseInt(20.0F * size)));
  jL.setBounds(0, top ? 0 : parseInt(91.0F * size), parseInt(163.0F * size), parseInt(30.0F * size));

  sImg = new BufferedImage(frameImg.getWidth(), frameImg.getHeight(), 2);

  Graphics g = sImg.getGraphics();
  Graphics2D g2 = (Graphics2D)g;

  g2.scale(size, size);

  if (top) { 
    g2.rotate(3.1415927410125732D, 82.0D, 60.0D);
  }
  g2.drawImage(frameImg, 0, 0, null);

  iL.setIcon(new ImageIcon(sImg));

  g2.dispose();
  g.dispose();

  sImg = new BufferedImage(dialImg.getWidth(), dialImg.getHeight(), 2);

  Graphics gg = sImg.getGraphics();
  Graphics2D gg2 = (Graphics2D)gg;

  gg2.scale(size, size);

  if (top) { 
    gg2.rotate(3.1415927410125732D, 73.0D, 48.0D);
  }
  gg2.setClip(new Rectangle2D.Float(0.0F, -25.0F, 200.0F, 100.0F));

  float diff = parseFloat(hour) * 60.0F + parseFloat(minute) + parseFloat(second) / 60.0F;
  float percentage = day ? diff / 100.0F : diff / 50.0F;



  if (day) {
    gg2.rotate((-90.0F + percentage * 180.0F) * 0.017453292F, 73.0D, 73.0D);
  } else {
    gg2.rotate((90.0F + percentage * 180.0F) * 0.017453292F, 73.0D, 73.0D);
  }
  gg2.drawImage(dialImg, 0, 0, null);

  iL2.setIcon(new ImageIcon(sImg));

  gg2.dispose();
  gg.dispose();
}

public void draw() {
  if (unixTime >= timeEnd) { 
    jL.setText("Getting time.");
    frameRate(0.0F);
    tryConnection(1);
  }

  WinDef.HWND fgWindow = User32.INSTANCE.GetForegroundWindow();
  int titleLength = User32.INSTANCE.GetWindowTextLength(fgWindow) + 1;
  char[] title = new char[titleLength];
  User32.INSTANCE.GetWindowText(fgWindow, title, titleLength);

  if (!moving) {
    if ((Native.toString(title).equals("WARFRAME")) && (cbShowIn.isSelected()) && (!show)) {
      thread("showSmooth");
    } else if ((!Native.toString(title).equals("WARFRAME")) && (cbShowIn.isSelected()) && (show)) {
      thread("hideSmooth");
    }
  }

  repaint();

  time += 1;
  if (time >= 2) {
    System.gc();
    time = 0;
  }
}

public void tryUpdate() {
  OUTPUT_FOLDER = System.getProperty("user.dir");
  TEMP_FOLDER = (System.getProperty("java.io.tmpdir") + "PoEClock");
  println(TEMP_FOLDER);
  try
  {
    r = new Scanner(new URL("https://raw.githubusercontent.com/Trane210/PoEClock/master/version.txt")
      .openStream());
    repoVer = r.next();
    dlPending = true;
  }
  catch (IOException e) {
    dlPending = false;
    e.printStackTrace();
  }
  println(new Object[] {currentVer, repoVer });
  if ((currentVer != null) && (currentVer.equals(repoVer))) {
    checkNotes(0);
  } else if (dlPending)
  {
    if (SystemTray.isSupported()) {
      trayIcon.displayMessage("Plains of Eidolon Clock", "An update is available, open the settings menu to update.", TrayIcon.MessageType.INFO);
    }
    settings.setSize(230, 180);
    sPanel.add(updateBtn);
    updateBtn.addActionListener(new ActionListener() {
      @Override
        public void actionPerformed(ActionEvent event) {
        preDownload();
        updateBtn.setEnabled(false);
      }
    }
    );
  }
}

public void checkNotes(int c) {
  if ((c == 1) || (!prefs.getBoolean("cetus_on_update", onUpdateDefault)))
  try {
    r = new Scanner(new URL("https://raw.githubusercontent.com/Trane210/PoEClock/master/changes.txt")
      .openStream());
    r.useDelimiter("\r\n");
    while (r.hasNext()) {
      patchNotes += r.next();
    }
    r.close();
    JTextArea textArea = new JTextArea(patchNotes);
    patchNotes = "";
    JScrollPane scrollPane = new JScrollPane(textArea);
    textArea.setEditable(false);
    textArea.setLineWrap(true);
    textArea.setWrapStyleWord(true);
    scrollPane.setPreferredSize(new Dimension(500, 500));

    Object[] options = { "Ok" };
    int jO = JOptionPane.showOptionDialog(null, scrollPane, "Patch notes", 0, 
      1, null, options, options[0]);
    if ((jO == 0) || (jO == -1))
      prefs.putBoolean("cetus_on_update", true);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

public void preDownload() {
  prefs.putBoolean("cetus_on_update", false);
  link = ("https://raw.githubusercontent.com/Trane210/PoEClock/master/v" + repoVer + ".zip");
  zipName = ("v" + repoVer + ".zip");
  INPUT_ZIP_FILE = zipName;
  println(OUTPUT_FOLDER);
  download();
}

public void download()
{
  jW.setVisible(false);
  settings.setVisible(false);
  trayIcon = null;


  jProgressBar.setMaximum(100000);
  frame = new JFrame();

  frame.addWindowListener(new WindowAdapter() {
    @Override
      public void windowClosing(WindowEvent windowEvent) {
      if (bool) {
        if (JOptionPane.showConfirmDialog(frame, "Are you sure?", "", 0, 3) == 0) {
          System.exit(0);
        }
      } else {
        try {
          //java.lang.Runtime.getRuntime().exec(new String[]{"cmd", "/c", "xcopy", "/C", "/E", "/I", "/Y", cetusTimer.access((cetusTimer)cetusTimer.this), cetusTimer.access((cetusTimer)cetusTimer.this), "&&", "rmdir", "/s", "/q", cetusTimer.access((cetusTimer)cetusTimer.this)}, null, new File(cetusTimer.access((cetusTimer)cetusTimer.this)));
          //???????

          System.exit(0);
        }
        catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }
  );
  frame.setDefaultCloseOperation(0);
  frame.setSize(300, 140);
  frame.setResizable(false);
  frame.setTitle("Updating");
  frame.setLocation(new Point(swidth / 2 - frame.getWidth() / 2, sheight / 2 - frame.getHeight() / 2));
  frame.setVisible(true);

  propane = new JLayeredPane();
  propane.setLayout(new GridLayout(0, 1));
  propane.add(jProgressBar);

  pane = new JPanel();
  pane.setLayout(new GridLayout(3, 0));
  pane.add(new JLabel("Downloading...", 0));
  pane.add(new JLabel(""));
  pane.add(propane, "South");

  frame.add(pane);


  Runnable updatethread = new Runnable() {
    @Override
      public void run() {
      try {
        URL url = new URL(link);
        HttpURLConnection httpConnection = (HttpURLConnection)url.openConnection();
        long completeFileSize = httpConnection.getContentLength();
        BufferedInputStream in = new BufferedInputStream(httpConnection.getInputStream());
        FileOutputStream fos = new FileOutputStream(zipName);
        BufferedOutputStream bout = new BufferedOutputStream(fos, 1024);
        byte[] data = new byte[1024];
        long downloadedFileSize = 0;
        int x = 0;
        while ((x = in.read(data, 0, 1024)) >= 0) {
          bool = true;
          final int currentProgress = (int)((double)(downloadedFileSize += (long)x) / (double)completeFileSize * 100000.0);
          SwingUtilities.invokeLater(new Runnable() {
            @Override
              public void run() {
              jProgressBar.setValue(currentProgress);
            }
          }
          );
          bout.write(data, 0, x);
        }
        bout.close();
        in.close();
        unZip();
      }
      catch (FileNotFoundException e) {
        e.printStackTrace();
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    }
  };
  new Thread(updatethread).start();
}

public void unZip()
{
  try {
    unzip(INPUT_ZIP_FILE, TEMP_FOLDER);
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

public void unzip(String zipFilePath, String destDirectory) throws IOException {
  pane.remove(0);
  pane.add(new JLabel("Unpacking...", 0), 0);
  frame.setContentPane(pane);

  File destDir = new File(destDirectory);

  if (!destDir.exists()) {
    destDir.mkdir();
  }
  ZipInputStream zipIn = new ZipInputStream(new FileInputStream(zipFilePath));

  ZipEntry entry = zipIn.getNextEntry();

  while (entry != null) {
    String filePath = destDirectory + File.separator + entry.getName();

    pane.remove(1);

    texta = new JTextArea(filePath);
    texta.setEditable(false);
    texta.setLineWrap(true);
    texta.setWrapStyleWord(true);
    texta.setOpaque(false);

    pane.add(texta, 1);

    frame.setContentPane(pane);

    println(filePath);
    if (!entry.isDirectory())
    {
      extractFile(zipIn, filePath);
    } else {
      File dir = new File(filePath);
      dir.mkdir();
    }
    zipIn.closeEntry();
    entry = zipIn.getNextEntry();
  }
  zipIn.close();
  File fzip = new File(INPUT_ZIP_FILE);
  fzip.delete();
  pane.remove(0);
  pane.add(new JLabel("Updated.", 0), 0);
  frame.setContentPane(pane);
  frame.setTitle("Updated");
  bool = false;
  println("done");
}

private void extractFile(ZipInputStream zipIn, String filePath) throws IOException {
  BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath, false));
  byte[] bytesIn = new byte[4096];
  int read = 0;
  while ((read = zipIn.read(bytesIn)) != -1) {
    bos.write(bytesIn, 0, read);
  }
  bos.close();
}
