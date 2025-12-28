//
//  Scratch.swift
//  SESATS10
//
//  Created by Edward Bender on 12/22/25.
//

/*
 AI prompt
 
 import FirebaseAILogic
 
 .task {
 let ai = FirebaseAI.firebaseAI(backend: .googleAI())
 let model = ai.generativeModel(modelName: "gemini-2.5-flash")
 
 let prompt = "Write a story about a magic backpack."
 let response = try! await model.generateContent(prompt)
 print(response.text ?? "No text in response.")
 }
 */


/*
 Response for breast cancer
 
 Given the information:
 *   **70-year-old woman**
 *   **PMH:**
     *   Left radical mastectomy + radiation therapy for breast cancer 20 years ago.
     *   Aortic Valve Replacement (AVR) via median sternotomy 8 years ago.
 *   **Current Issue:** Chest wall lesion (shown in photographs, which I cannot see).

 The "best management" cannot be definitively stated without seeing the photographs and performing a clinical assessment. However, I can provide the most up-to-date diagnostic and management approach based on the *potential* diagnoses in this complex scenario.

 ---

 ### **Crucial Initial Steps (Before any definitive management):**

 1.  **Detailed History and Physical Examination:**
     *   **Lesion characteristics:** When did it appear? How has it changed (size, shape, color, pain, itching, bleeding, discharge)? Is it singular or multiple?
     *   **Associated symptoms:** Any systemic symptoms (fever, weight loss, fatigue)? Any pain, numbness, or weakness in the arm/chest wall?
     *   **Review of systems:** Especially relevant to potential metastatic disease.
     *   **Physical Exam:** Meticulous inspection and palpation of the lesion (size, shape, color, texture, mobility, tenderness, depth of invasion). Assess the entire chest wall, axilla, supraclavicular regions for lymphadenopathy, and the contralateral breast. Examine the sternotomy scar.

 2.  **Biopsy of the Lesion:** This is the *most critical* step for definitive diagnosis. The type of biopsy depends on the lesion's characteristics (size, depth, location):
     *   **Punch biopsy:** For superficial skin lesions.
     *   **Incisional biopsy:** For larger or deeper lesions where complete excision is not initially feasible or desired.
     *   **Excisional biopsy:** If the lesion is small and easily removable with a reasonable margin, it can be both diagnostic and therapeutic.
     *   **Pathology:** The biopsy must be reviewed by an experienced dermatopathologist/surgical pathologist. Special stains (e.g., ER/PR/HER2 for breast cancer recurrence, CD31/CD34/ERG for angiosarcoma, keratin/vimentin for others) and potentially molecular profiling will be crucial.

 ---

 ### **Differential Diagnosis (Given the History):**

 The broad differential for a chest wall lesion in this patient includes:

 **A. Related to Prior Breast Cancer/Radiation (most concerning):**

 1.  **Local Recurrence of Breast Cancer:** This is a primary concern. It can manifest as a nodule, skin changes (peau d'orange, erythema), or ulceration on the chest wall, often in the mastectomy scar or previously irradiated field.
 2.  **Radiation-Induced Sarcoma:** A rare but aggressive complication of radiation therapy, typically occurring 10-20+ years post-treatment. Angiosarcoma is a specific subtype that can appear as violaceous plaques or nodules, often mistaken for benign vascular lesions. Other sarcomas (e.g., fibrosarcoma, osteosarcoma) are also possible, especially if bone/cartilage is involved.
 3.  **Radiation-Induced Atypical Vascular Lesion (AVL):** A benign proliferation of atypical blood vessels that can be difficult to distinguish from low-grade angiosarcoma, even pathologically. Long-term follow-up is essential.
 4.  **Metastatic Breast Cancer:** Distant metastasis that has localized to the chest wall.
 5.  **New Primary Breast Cancer:** Less likely to be called a "chest wall lesion" but possible if in residual breast tissue or the contralateral breast.
 6.  **Skin Cancers (BCC, SCC, Melanoma):** Radiation exposure increases the risk of these cancers in the irradiated field.

 **B. Related to Prior Sternotomy/AVR:**

 1.  **Keloid or Hypertrophic Scar:** Benign scar tissue overgrowth, especially possible at a sternotomy site.
 2.  **Sternal Dehiscence/Osteomyelitis:** Less likely 8 years out unless chronic or reactivated, but a possibility if there's pain, swelling, or drainage associated with the sternum.
 3.  **Sternal Tumor:** Primary bone tumor (very rare) or metastasis to the sternum.

 **C. Benign/Unrelated Skin Lesions:**

 1.  **Lipoma:** Benign fatty tumor.
 2.  **Seborrheic Keratosis, Dermatofibroma, Cysts:** Common benign skin lesions.
 3.  **Infection:** Folliculitis, furuncle, abscess.

 ---

 ### **Further Workup (Once Biopsy Results Are Available or Highly Suspicious):**

 **A. Imaging:**

 1.  **Local Imaging:**
     *   **Ultrasound:** To assess the depth, vascularity, and relationship of the lesion to underlying structures (muscle, ribs).
     *   **MRI of the Chest Wall:** Highly recommended for suspected malignancy (recurrence, sarcoma). It provides excellent soft tissue contrast, defines the extent of local invasion (e.g., into muscle, bone, pleura), and evaluates regional lymph nodes.
     *   **CT Scan of the Chest:** To assess for deeper chest wall involvement, rib or sternal invasion, and intrathoracic extension. Also helps evaluate the mediastinum and lungs for metastatic disease.

 2.  **Staging Imaging (if malignancy is suspected):**
     *   **CT Chest/Abdomen/Pelvis:** To look for distant metastatic disease.
     *   **Bone Scan:** If there is suspicion of bone metastases (e.g., pain, elevated alkaline phosphatase).
     *   **PET/CT Scan:** Can be very useful for comprehensive staging of local recurrence or sarcoma, assessing metabolic activity of the lesion, and identifying distant metastases.

 **B. Laboratory Studies:**
 *   Routine labs (CBC, metabolic panel).
 *   Tumor markers (e.g., CA 27-29, CEA) if recurrence of breast cancer is highly suspected, for baseline and monitoring.

 ---

 ### **Best Management Based on Potential Diagnoses (Most Up-to-Date):**

 **I. If Local Recurrence of Breast Cancer:**

 *   **Multidisciplinary Tumor Board Discussion:** Essential for complex cases involving prior radiation and surgery. Team includes surgical oncologist, radiation oncologist, medical oncologist, plastic surgeon.
 *   **Treatment Approach:** Highly individualized.
     *   **Surgery:** Wide local excision with clear margins is generally the mainstay. This can be challenging in a previously irradiated and operated field and may require complex chest wall reconstruction (e.g., using synthetic mesh, muscle flaps from other sites).
     *   **Re-irradiation:** Possible in selected cases, especially if the initial radiation dose was suboptimal or if significant time has passed. However, the risk of toxicity (e.g., radiation necrosis) is higher. Proton therapy or brachytherapy may be considered for highly conformal re-irradiation.
     *   **Systemic Therapy:** Based on the tumor's biology (ER/PR/HER2 status), prior treatments, and extent of disease (e.g., hormonal therapy, chemotherapy, targeted therapy like HER2-directed agents, CDK4/6 inhibitors).
     *   **Prognosis:** Varies greatly with the extent of recurrence, disease-free interval, and tumor biology.

 **II. If Radiation-Induced Sarcoma (e.g., Angiosarcoma):**

 *   **Aggressive Management:** These are highly aggressive tumors with high local recurrence and metastatic rates.
 *   **Surgery:** Wide local excision with unequivocally clear margins is paramount. This often means extensive chest wall resection.
 *   **Adjuvant Therapy:** The role of adjuvant radiation or chemotherapy is less clear but may be considered for high-grade tumors or positive margins, often in a clinical trial setting.
 *   **Prognosis:** Generally poor, making early and aggressive intervention crucial.

 **III. If Primary Skin Cancer (BCC, SCC, Melanoma):**

 *   **Basal Cell Carcinoma (BCC) / Squamous Cell Carcinoma (SCC):**
     *   **Excision:** Wide local excision with appropriate margins. Mohs micrographic surgery may be considered for certain high-risk lesions or cosmetic areas, but can be challenging on a previously radiated chest wall.
     *   **Adjuvant Radiation:** Rare, for very aggressive SCCs or positive margins not amenable to further surgery.
 *   **Melanoma:**
     *   **Excision:** Wide local excision with margins determined by lesion depth.
     *   **Sentinel Lymph Node Biopsy:** May be indicated for lesions over a certain depth (typically >0.8mm or with ulceration).
     *   **Adjuvant Therapy:** Systemic therapies (immunotherapy, targeted therapy) are increasingly used for high-risk resected melanoma.

 **IV. If Atypical Vascular Lesion (AVL):**

 *   **Excision:** Complete excision is recommended if possible, primarily to rule out low-grade angiosarcoma and for long-term surveillance.
 *   **Close Follow-up:** Regular clinical exams due to the potential for recurrence or transformation to angiosarcoma.

 **V. If Benign Lesion (Lipoma, Cyst, Hypertrophic Scar, etc.):**

 *   **Observation:** If asymptomatic and no cosmetic concern.
 *   **Simple Excision:** If symptomatic, causing discomfort, or for cosmetic reasons.

 ---

 ### **General Considerations for This Patient:**

 *   **Patient's Age and Comorbidities:** At 70, the patient's overall health, cardiac status (post-AVR), and fitness for extensive surgery or intensive systemic therapy must be carefully assessed.
 *   **Previous Radiation Field:** The challenge of re-operating in a radiated field includes poor wound healing, increased risk of infection, and potential damage to underlying structures.
 *   **Previous Sternotomy:** Operating on the chest wall near or involving the sternum post-AVR requires careful planning to avoid the heart and great vessels, and manage potential sternal instability.
 *   **Psychosocial Support:** A new lesion can cause significant anxiety and distress, especially with a history of cancer. Emotional support and clear communication are vital.

 ---

 **In summary, the best management begins with a thorough clinical assessment, detailed imaging, and crucially, a definitive biopsy with expert pathological review. This guides a multidisciplinary team to formulate a personalized treatment plan that balances radical cancer treatment with the patient's overall health and quality of life.**
 */
