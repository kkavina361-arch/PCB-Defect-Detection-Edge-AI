# =========================================================
# FPGA EDGE AI PCB DEFECT DETECTION
# FINAL ONE BUTTON INDUSTRIAL VERSION
#
# ✔ USB CAMERA LIVE VIEW
# ✔ BTN0 CAPTURE
# ✔ BTN0 AGAIN -> NEXT CAPTURE
# ✔ HOLDS RESULT SCREEN
# ✔ HDMI DASHBOARD
# ✔ PERFECT ALIGNMENT
# ✔ HORIZONTAL INDICATORS
# ✔ NO TIMER
# ✔ INDUSTRIAL EDGE DEVICE STYLE
# ✔ YOLOv8n ONNX
#
# BTN0 WORKFLOW:
#
# PRESS BTN0
#     ↓
# CAPTURE PCB
#     ↓
# DETECT DEFECTS
#     ↓
# HOLD RESULT SCREEN
#     ↓
# PRESS BTN0 AGAIN
#     ↓
# NEXT PCB CAPTURE
#
# =========================================================

import onnxruntime as ort
import numpy as np
import cv2
import time

from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

from pynq.overlays.base import BaseOverlay
from pynq.lib.video import VideoMode


# =========================================================
# HDMI INITIALIZATION
# =========================================================
base = BaseOverlay("base.bit")

hdmi_out = base.video.hdmi_out

try:
    hdmi_out.stop()
except:
    pass

time.sleep(1)

hdmi_out.configure(
    VideoMode(1280,720,24)
)

hdmi_out.start()

time.sleep(2)

print("HDMI READY")


# =========================================================
# BUTTON
# =========================================================
btn0 = base.buttons[0]


# =========================================================
# CONFIG
# =========================================================
model_path = "best1.onnx"

img_size = 416

conf_threshold = 0.25

iou_threshold = 0.45


# =========================================================
# CLASS NAMES
# =========================================================
class_names = [
    "mouse_bite",
    "spur",
    "missing_hole",
    "short",
    "open_circuit",
    "spurious_copper"
]


# =========================================================
# REWORKABLE CLASSES
# =========================================================
reworkable_classes = [
    "mouse_bite",
    "spur",
    "spurious_copper"
]


# =========================================================
# LOAD MODEL
# =========================================================
session = ort.InferenceSession(
    model_path,
    providers=["CPUExecutionProvider"]
)

input_name = session.get_inputs()[0].name

output_name = session.get_outputs()[0].name

print("MODEL LOADED")


# =========================================================
# NMS
# =========================================================
def nms(boxes, scores, iou_thresh):

    if len(boxes) == 0:
        return []

    boxes = np.array(boxes)

    scores = np.array(scores)

    x1 = boxes[:,0]
    y1 = boxes[:,1]
    x2 = boxes[:,2]
    y2 = boxes[:,3]

    areas = (x2-x1)*(y2-y1)

    order = scores.argsort()[::-1]

    keep = []

    while order.size > 0:

        i = order[0]

        keep.append(i)

        xx1 = np.maximum(
            x1[i],
            x1[order[1:]]
        )

        yy1 = np.maximum(
            y1[i],
            y1[order[1:]]
        )

        xx2 = np.minimum(
            x2[i],
            x2[order[1:]]
        )

        yy2 = np.minimum(
            y2[i],
            y2[order[1:]]
        )

        w = np.maximum(
            0.0,
            xx2-xx1
        )

        h = np.maximum(
            0.0,
            yy2-yy1
        )

        inter = w*h

        union = (
            areas[i]
            + areas[order[1:]]
            - inter
            + 1e-6
        )

        iou = inter / union

        order = order[1:][iou < iou_thresh]

    return keep


# =========================================================
# FONTS
# =========================================================
try:

    font_title = ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        32
    )

    font_big = ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        24
    )

    font_small = ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        18
    )

except:

    font_title = ImageFont.load_default()

    font_big = ImageFont.load_default()

    font_small = ImageFont.load_default()


# =========================================================
# USB CAMERA
# =========================================================
cap = cv2.VideoCapture(0)

cap.set(cv2.CAP_PROP_FRAME_WIDTH,1280)

cap.set(cv2.CAP_PROP_FRAME_HEIGHT,720)

if not cap.isOpened():

    raise RuntimeError(
        "USB CAMERA NOT DETECTED"
    )

print("USB CAMERA READY")
print("PRESS BTN0 TO CAPTURE")


# =========================================================
# DISPLAY MODE
# =========================================================
show_dashboard = False


# =========================================================
# MAIN LOOP
# =========================================================
while True:

    # =====================================================
    # LIVE CAMERA MODE
    # =====================================================
    if not show_dashboard:

        ret, frame_bgr = cap.read()

        if not ret:
            continue

        live_view = cv2.resize(
            frame_bgr,
            (1280,720)
        )

        live_frame = hdmi_out.newframe()

        live_frame[:] = live_view

        hdmi_out.writeframe(live_frame)


        # =================================================
        # BTN0 -> CAPTURE
        # =================================================
        if btn0.read() == 1:

            print("CAPTURE STARTED")

            time.sleep(0.5)

            ret, frame_bgr = cap.read()

            if not ret:
                continue


            # =============================================
            # RGB
            # =============================================
            frame_rgb = cv2.cvtColor(
                frame_bgr,
                cv2.COLOR_BGR2RGB
            )

            h0, w0 = frame_rgb.shape[:2]


            # =============================================
            # PREPROCESS
            # =============================================
            img_resized = cv2.resize(
                frame_rgb,
                (img_size,img_size)
            )

            img_input = img_resized.astype(np.float32) / 255.0

            img_input = np.transpose(
                img_input,
                (2,0,1)
            )[None]


            # =============================================
            # INFERENCE
            # =============================================
            start_time = time.time()

            pred = session.run(
                [output_name],
                {input_name: img_input}
            )[0]

            latency = time.time() - start_time

            fps = 1 / latency if latency > 0 else 0


            # =============================================
            # OUTPUT SHAPE
            # =============================================
            pred = pred[0].transpose()


            # =============================================
            # POSTPROCESS
            # =============================================
            boxes = []

            scores = []

            classes = []

            for p in pred:

                x, y, w, h = p[:4]

                class_scores = p[4:]

                cls = int(np.argmax(class_scores))

                score = float(class_scores[cls])

                if score < conf_threshold:
                    continue

                x1 = max((x-w/2)*w0/img_size,0)

                y1 = max((y-h/2)*h0/img_size,0)

                x2 = min((x+w/2)*w0/img_size,w0)

                y2 = min((y+h/2)*h0/img_size,h0)

                boxes.append([x1,y1,x2,y2])

                scores.append(score)

                classes.append(cls)


            # =============================================
            # APPLY NMS
            # =============================================
            keep_idx = nms(
                boxes,
                scores,
                iou_threshold
            )

            boxes = [boxes[i] for i in keep_idx]

            scores = [scores[i] for i in keep_idx]

            classes = [classes[i] for i in keep_idx]


            # =============================================
            # ACCURACY
            # =============================================
            if len(scores) > 0:

                accuracy = np.mean(scores) * 100

            else:

                accuracy = 100.0


            # =============================================
            # STATUS
            # =============================================
            if len(boxes) > 0:

                pcb_status = "DEFECT DETECTED"

                indicator_color = "red"

            else:

                pcb_status = "NO DEFECT"

                indicator_color = "green"


            # =============================================
            # DRAW DETECTIONS
            # =============================================
            draw_img = Image.fromarray(frame_rgb)

            draw_ctx = ImageDraw.Draw(draw_img)

            for b, s, c in zip(boxes,scores,classes):

                draw_ctx.rectangle(
                    b,
                    outline="lime",
                    width=4
                )

                draw_ctx.text(
                    (b[0]+5,b[1]+5),
                    f"{class_names[c]} {s:.2f}",
                    fill="yellow",
                    font=font_small
                )


            # =============================================
            # CREATE DASHBOARD
            # =============================================
            report_img = Image.new(
                "RGB",
                (1280,720),
                "white"
            )

            draw = ImageDraw.Draw(report_img)


            # =============================================
            # TITLE
            # =============================================
            draw.text(
                (250,20),
                "PCB DEFECT DETECTION DASHBOARD",
                fill="black",
                font=font_title
            )


            # =============================================
            # LEFT PANEL
            # =============================================
            y = 110

            draw.text(
                (40,y),
                f"Accuracy : {accuracy:.2f} %",
                fill="black",
                font=font_big
            )

            y += 50

            draw.text(
                (40,y),
                f"Latency : {latency:.2f} sec",
                fill="black",
                font=font_big
            )

            y += 50

            draw.text(
                (40,y),
                f"FPS : {fps:.2f}",
                fill="black",
                font=font_big
            )

            y += 50

            draw.text(
                (40,y),
                f"Defects : {len(boxes)}",
                fill="black",
                font=font_big
            )

            y += 50

            draw.text(
                (40,y),
                f"Status : {pcb_status}",
                fill=indicator_color,
                font=font_big
            )

            y += 70


            # =============================================
            # DEFECT DETAILS
            # =============================================
            draw.text(
                (40,y),
                "Defect Details:",
                fill="blue",
                font=font_big
            )

            y += 40

            if len(classes) > 0:

                for cls in classes:

                    defect_name = class_names[cls]

                    if defect_name in reworkable_classes:

                        rw = "REWORKABLE"

                    else:

                        rw = "NON-REWORKABLE"

                    draw.text(
                        (60,y),
                        f"- {defect_name} --> {rw}",
                        fill="blue",
                        font=font_small
                    )

                    y += 30

            else:

                draw.text(
                    (60,y),
                    "- NONE",
                    fill="green",
                    font=font_small
                )


            # =============================================
            # DIVIDER
            # =============================================
            draw.line(
                [(620,70),(620,650)],
                fill="blue",
                width=3
            )


            # =============================================
            # IMAGE BORDER
            # =============================================
            draw.rectangle(
                [(680,80),(1220,520)],
                outline="black",
                width=5
            )


            # =============================================
            # DETECTED IMAGE
            # =============================================
            det_img_resized = draw_img.resize(
                (520,420)
            )

            report_img.paste(
                det_img_resized,
                (690,90)
            )


            # =============================================
            # STATUS BAR
            # =============================================
            draw.rectangle(
                [(700,550),(1180,600)],
                fill=indicator_color
            )

            draw.text(
                (810,560),
                pcb_status,
                fill="white",
                font=font_big
            )


            # =============================================
            # HORIZONTAL INDICATORS
            # =============================================
            draw.ellipse(
                [(700,620),(770,690)],
                fill="red",
                outline="black",
                width=3
            )

            draw.text(
                (790,640),
                "DEFECT",
                fill="red",
                font=font_big
            )

            draw.ellipse(
                [(980,620),(1050,690)],
                fill="green",
                outline="black",
                width=3
            )

            draw.text(
                (1070,640),
                "NO DEFECT",
                fill="green",
                font=font_big
            )


            # =============================================
            # HDMI OUTPUT
            # =============================================
            output = np.array(report_img).astype(np.uint8)

            frame_out = hdmi_out.newframe()

            frame_out[:] = output

            hdmi_out.writeframe(frame_out)

            print("RESULT DISPLAYED")

            show_dashboard = True


            # =============================================
            # WAIT BUTTON RELEASE
            # =============================================
            while btn0.read() == 1:
                pass

            time.sleep(0.5)


    # =====================================================
    # HOLD DASHBOARD SCREEN
    # =====================================================
    else:

        # =============================================
        # PRESS BTN0 AGAIN FOR NEXT PCB
        # =============================================
        if btn0.read() == 1:

            print("RETURN TO LIVE CAMERA")

            show_dashboard = False

            while btn0.read() == 1:
                pass

            time.sleep(0.5)


# =========================================================
# RELEASE
# =========================================================
cap.release()

cv2.destroyAllWindows()
